/*
 * Security.h - Password hashing, session tokens, and validation helpers
 *
 * Password storage uses PBKDF2-HMAC-SHA256 (200k iterations) via OpenSSL,
 * encoded as: pbkdf2_sha256$<iterations>$<base64(salt)>$<base64(hash)>
 *
 * Note on Argon2: OpenSSL 3.2+ provides Argon2 via the 'argon2' provider.
 * If available, we use argon2id; otherwise we fall back to PBKDF2-SHA256
 * with high iteration count, which is still strong for offline attack defense.
 */
#pragma once

#include <QString>
#include <QByteArray>
#include <QObject>

namespace mms {

class Security : public QObject {
    Q_OBJECT
public:
    static Security& instance();

    // Generate a cryptographically random salt of the given byte length
    static QByteArray generateSalt(int bytes = 32);

    // Hash a password with a given salt. Returns the encoded string
    // (algorithm$iterations$salt_b64$hash_b64). Uses Argon2id if available,
    // otherwise PBKDF2-SHA256 with 200,000 iterations.
    QString hashPassword(const QString& password, const QByteArray& salt);

    // Verify a password against an encoded hash
    bool verifyPassword(const QString& password, const QString& encodedHash);

    // Generate a random session token (URL-safe base64)
    static QString generateToken(int bytes = 32);

    // Generate a random receipt/certificate number seed
    static QString generateReference(const QString& prefix, int length = 6);

    // Generate a QR payload for a certificate
    static QString generateQrPayload(const QString& certType, qint64 certId, const QString& certNumber);

    // Input validation helpers
    static bool isValidEmail(const QString& email);
    static bool isValidPhone(const QString& phone);
    static bool isValidPincode(const QString& pincode);
    static bool isStrongPassword(const QString& password);
    static QString sanitizeFilename(const QString& name);

    // Password strength score (0-5)
    static int passwordStrength(const QString& password);

    // Constant-time string comparison
    static bool constantTimeCompare(const QByteArray& a, const QByteArray& b);

private:
    Security();
    ~Security() override;
    Security(const Security&) = delete;
    Security& operator=(const Security&) = delete;

    bool tryArgon2Available();
    bool argon2Available_ = false;
};

} // namespace mms
