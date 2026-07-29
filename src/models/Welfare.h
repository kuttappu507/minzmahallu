/*
 * Welfare.h - Welfare request model
 */
#pragma once

#include <QString>
#include <QDateTime>
#include <QSqlQuery>
#include <QSqlRecord>

namespace mms {

struct WelfareRequest {
    qint64 id = 0;
    QString requestNumber;
    QString applicantName;
    qint64 familyId = 0;
    QString category;          // Medical Aid, Education Aid, Marriage Assistance, Financial Assistance
    double amountRequested = 0;
    double amountApproved = 0;
    QString reason;
    QString status = "Pending"; // Pending, Approved, Rejected, Disbursed, Closed
    qint64 approvedBy = 0;
    QString disbursedDate;
    QString remarks;
    QDateTime createdAt;
    QDateTime updatedAt;

    // Joined
    QString familyNumber;
    QString approvedByName;

    static WelfareRequest fromQuery(const QSqlQuery& q) {
        WelfareRequest w;
        w.id = q.value("id").toLongLong();
        w.requestNumber = q.value("request_number").toString();
        w.applicantName = q.value("applicant_name").toString();
        w.familyId = q.value("family_id").toLongLong();
        w.category = q.value("category").toString();
        w.amountRequested = q.value("amount_requested").toDouble();
        w.amountApproved = q.value("amount_approved").toDouble();
        w.reason = q.value("reason").toString();
        w.status = q.value("status").toString();
        w.approvedBy = q.value("approved_by").toLongLong();
        w.disbursedDate = q.value("disbursed_date").toString();
        w.remarks = q.value("remarks").toString();
        w.createdAt = QDateTime::fromString(q.value("created_at").toString(), Qt::ISODate);
        w.updatedAt = QDateTime::fromString(q.value("updated_at").toString(), Qt::ISODate);

        int idx = q.record().indexOf("family_number");
        if (idx >= 0) w.familyNumber = q.value(idx).toString();
        idx = q.record().indexOf("approved_by_name");
        if (idx >= 0) w.approvedByName = q.value(idx).toString();
        return w;
    }
};

} // namespace mms
