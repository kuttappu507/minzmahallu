/*
 * CertificateRepository.h - Certificates & documents
 */
#pragma once

#include "../models/AuditLog.h"   // Certificate, Document structs live here
#include <vector>
#include <optional>
#include <QString>

namespace mms {

class CertificateRepository {
public:
    std::optional<Certificate> findById(qint64 id);
    std::optional<Certificate> findByNumber(const QString& num);

    std::vector<Certificate> list(int page = 1, int pageSize = 50,
                                  const QString& typeFilter = QString(),
                                  const QString& dateFrom = QString(),
                                  const QString& dateTo = QString(),
                                  int* totalOut = nullptr);

    QString generateNumber(const QString& type);
    qint64 create(Certificate& c);
    bool remove(qint64 id);

    int countByType(const QString& type);
    int countThisYear();
};

class DocumentRepository {
public:
    std::vector<Document> listFor(const QString& module, qint64 linkedId);
    std::optional<Document> findById(qint64 id);

    qint64 create(Document& d);
    bool remove(qint64 id);
    bool removeForLink(const QString& module, qint64 linkedId);
    int countForLink(const QString& module, qint64 linkedId);
};

} // namespace mms
