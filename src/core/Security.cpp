/*
 * Security.cpp - Implementation
 *
 * Uses OpenSSL's EVP API for password hashing.
 */
#include "Security.h"
#include "Logger.h"

#include <openssl/evp.h>
#include <openssl/rand.h>
#include <openssl/kdf.h>
#include <openssl/params.h>
#include <openssl/core_names.h>

#include <QRegularExpression>
#include <QDateTime>
#include <QCryptographicHash>
#include <QRandomGenerator>

namespace mms {

Security& Security::instance() {
    static Security inst;
    return inst;
}

Security::Security() {
    argon2Available_ = tryArgon2Available();
    Logger::info(QString("Security initialized. Argon2 available: %1")
                 .arg(argon2Available_ ? "yes" : "no (using PBKDF2-SHA256 fallback)"));
}

Security::~Security() = default;

bool Security::tryArgon2Available() {
    // Argon2 KDF requires OpenSSL 3.2+. On older OpenSSL, fall back to PBKDF2.
#if OPENSSL_VERSION_NUMBER >= 0x30200000L
    EVP_KDF* kdf = EVP_KDF_fetch(nullptr, "ARGON2ID", nullptr);
    if (kdf) {
        EVP_KDF_free(kdf);
        return true;
    }
#endif
    return false;
}

QByteArray Security::generateSalt(int bytes) {
    QByteArray buf(bytes, '\0');
    if (RAND_bytes(reinterpret_cast<unsigned char*>(buf.data()), bytes) != 1) {
        // Fallback (less ideal): use Qt's random generator
        for (int i = 0; i < bytes; ++i) {
            buf[i] = static_cast<char>(QRandomGenerator::global()->generate() & 0xFF);
        }
    }
    return buf;
}

static QByteArray pbkdf2Hash(const QString& password, const QByteArray& salt, int iterations, int dkLen = 32) {
    QByteArray out(dkLen, '\0');
    int rc = PKCS5_PBKDF2_HMAC(
        password.toUtf8().constData(),
        password.toUtf8().size(),
        reinterpret_cast<const unsigned char*>(salt.constData()),
        salt.size(),
        iterations,
        EVP_sha256(),
        dkLen,
        reinterpret_cast<unsigned char*>(out.data())
    );
    if (rc != 1) {
        Logger::error("PBKDF2 hashing failed");
        return {};
    }
    return out;
}

#if OPENSSL_VERSION_NUMBER >= 0x30200000L
static bool argon2idHash(const QString& password, const QByteArray& salt,
                         QByteArray& out, int dkLen = 32) {
    EVP_KDF* kdf = EVP_KDF_fetch(nullptr, "ARGON2ID", nullptr);
    if (!kdf) return false;

    EVP_KDF_CTX* ctx = EVP_KDF_CTX_new(kdf);
    EVP_KDF_free(kdf);
    if (!ctx) return false;

    QByteArray pwd = password.toUtf8();
    out.resize(dkLen);

    OSSL_PARAM params[6];
    int i = 0;
    params[i++] = OSSL_PARAM_construct_octet_string(OSSL_KDF_PARAM_PASSWORD,
                                                     pwd.data(), pwd.size());
    params[i++] = OSSL_PARAM_construct_octet_string(OSSL_KDF_PARAM_SALT,
                                                     const_cast<char*>(salt.constData()), salt.size());
    uint64_t iter = 3;
    uint64_t mem  = 65536;  // 64 MB
    uint64_t lanes = 4;
    params[i++] = OSSL_PARAM_construct_uint64(OSSL_KDF_PARAM_ITER, &iter);
    params[i++] = OSSL_PARAM_construct_uint64(OSSL_KDF_PARAM_SCRYPT_N, &mem);
    params[i++] = OSSL_PARAM_construct_uint64(OSSL_KDF_PARAM_THREADS, &lanes);
    params[i++] = OSSL_PARAM_construct_end();

    int rc = EVP_KDF_derive(ctx, reinterpret_cast<unsigned char*>(out.data()), dkLen, params);
    EVP_KDF_CTX_free(ctx);
    return rc == 1;
}
#else
// OpenSSL < 3.2 stub — Argon2 unavailable, always returns false so caller
// falls back to PBKDF2.
static bool argon2idHash(const QString&, const QByteArray&, QByteArray&, int = 32) {
    return false;
}
#endif

QString Security::hashPassword(const QString& password, const QByteArray& salt) {
    QByteArray hash;
    QString algo;

    if (argon2Available_) {
        if (argon2idHash(password, salt, hash)) {
            algo = "argon2id";
        } else {
            hash = pbkdf2Hash(password, salt, 200000);
            algo = "pbkdf2_sha256";
        }
    } else {
        hash = pbkdf2Hash(password, salt, 200000);
        algo = "pbkdf2_sha256";
    }

    return QString("%1$%2$%3$%4")
        .arg(algo)
        .arg(algo.startsWith("pbkdf2") ? 200000 : 3)
        .arg(QString::fromUtf8(salt.toBase64()))
        .arg(QString::fromUtf8(hash.toBase64()));
}

bool Security::verifyPassword(const QString& password, const QString& encodedHash) {
    if (encodedHash.isEmpty()) return false;
    auto parts = encodedHash.split('$');
    if (parts.size() != 4) return false;

    QString algo = parts[0];
    bool ok = false;
    int iterations = parts[1].toInt(&ok);
    QByteArray salt   = QByteArray::fromBase64(parts[2].toUtf8());
    QByteArray stored = QByteArray::fromBase64(parts[3].toUtf8());

    if (!ok || salt.isEmpty() || stored.isEmpty()) return false;

    QByteArray computed;
    if (algo == "argon2id") {
        if (!argon2idHash(password, salt, computed, stored.size())) {
            // fall through to PBKDF2 attempt
            algo = "pbkdf2_sha256";
            iterations = 200000;
        }
    }
    if (algo == "pbkdf2_sha256") {
        computed = pbkdf2Hash(password, salt, iterations, stored.size());
    }

    return constantTimeCompare(computed, stored);
}

QString Security::generateToken(int bytes) {
    return QString::fromUtf8(generateSalt(bytes).toBase64(QByteArray::Base64UrlEncoding | QByteArray::OmitTrailingEquals));
}

QString Security::generateReference(const QString& prefix, int length) {
    QByteArray raw = generateSalt(length);
    // Convert to uppercase alphanumeric
    QString chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    QString out;
    for (int i = 0; i < length; ++i) {
        int idx = static_cast<unsigned char>(raw[i]) % chars.size();
        out.append(chars[idx]);
    }
    return prefix + "-" + out;
}

QString Security::generateQrPayload(const QString& certType, qint64 certId, const QString& certNumber) {
    // Format: MMS|<type>|<id>|<number>|<timestamp>
    return QString("MMS|%1|%2|%3|%4")
        .arg(certType)
        .arg(certId)
        .arg(certNumber)
        .arg(QDateTime::currentDateTime().toSecsSinceEpoch());
}

bool Security::isValidEmail(const QString& email) {
    if (email.isEmpty()) return true; // optional field
    static const QRegularExpression re(R"(^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$)");
    return re.match(email).hasMatch();
}

bool Security::isValidPhone(const QString& phone) {
    if (phone.isEmpty()) return true;
    // Accept Indian phone format primarily, also international with +
    static const QRegularExpression re(R"(^(\+?\d{1,3}[-\s]?)?\d{10}$)");
    return re.match(phone).hasMatch();
}

bool Security::isValidPincode(const QString& pincode) {
    if (pincode.isEmpty()) return true;
    static const QRegularExpression re(R"(^\d{6}$)");
    return re.match(pincode).hasMatch();
}

bool Security::isStrongPassword(const QString& password) {
    if (password.length() < 8) return false;
    bool hasUpper  = false, hasLower = false, hasDigit = false, hasSpecial = false;
    for (QChar c : password) {
        if (c.isUpper())  hasUpper = true;
        else if (c.isLower()) hasLower = true;
        else if (c.isDigit()) hasDigit = true;
        else hasSpecial = true;
    }
    return hasUpper && hasLower && hasDigit && hasSpecial;
}

QString Security::sanitizeFilename(const QString& name) {
    QString out = name;
    out.replace(QRegularExpression(R"([<>:"/\\|?*\x00-\x1f])"), "_");
    out = out.trimmed();
    if (out.isEmpty()) out = "untitled";
    if (out.length() > 200) out = out.left(200);
    return out;
}

int Security::passwordStrength(const QString& password) {
    int score = 0;
    if (password.length() >= 8)  ++score;
    if (password.length() >= 12) ++score;
    bool hasUpper = false, hasLower = false, hasDigit = false, hasSpecial = false;
    for (QChar c : password) {
        if (c.isUpper())  hasUpper = true;
        else if (c.isLower()) hasLower = true;
        else if (c.isDigit()) hasDigit = true;
        else hasSpecial = true;
    }
    if (hasUpper && hasLower) ++score;
    if (hasDigit) ++score;
    if (hasSpecial) ++score;
    return std::min(score, 5);
}

bool Security::constantTimeCompare(const QByteArray& a, const QByteArray& b) {
    if (a.size() != b.size()) return false;
    unsigned char diff = 0;
    for (int i = 0; i < a.size(); ++i) {
        diff |= static_cast<unsigned char>(a[i] ^ b[i]);
    }
    return diff == 0;
}

} // namespace mms
