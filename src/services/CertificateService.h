/*
 * CertificateService.h - Generate PDF certificates with QR codes
 */
#pragma once

#include "../models/AuditLog.h"   // Certificate struct
#include <QString>
#include <vector>

namespace mms {

class CertificateService {
public:
    enum class CertType {
        Membership, Residence, Marriage, Death, Character, Income
    };
    static QString typeToString(CertType t);
    static CertType stringToType(const QString& s);

    // Issue a certificate and return its id. Fills in c.certificateNumber and qrPayload.
    qint64 issueCertificate(Certificate& c, QString* errorMsg = nullptr);

    std::vector<Certificate> list(int page = 1, int pageSize = 50,
                                  const QString& typeFilter = QString(),
                                  const QString& dateFrom = QString(),
                                  const QString& dateTo = QString(),
                                  int* totalOut = nullptr);

    // Generate PDF for a certificate; returns the output PDF path.
    QString generatePdf(qint64 certificateId, QString* errorMsg = nullptr);

    // Direct PDF generation for a marriage certificate
    QString generateMarriageCertificatePdf(qint64 marriageId, QString* errorMsg = nullptr);

    // Direct PDF generation for a death certificate
    QString generateDeathCertificatePdf(qint64 deathId, QString* errorMsg = nullptr);

private:
    QString renderTemplate(const QString& templateName,
                           const std::map<QString, QString>& vars);
    QString drawQrCode(const QString& payload, const QString& outPath);
};

} // namespace mms
