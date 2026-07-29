/*
 * ReportService.cpp
 */
#include "ReportService.h"
#include "../core/Database.h"
#include "../core/Config.h"
#include "../core/Logger.h"
#include "../repositories/AuditLogRepository.h"
#include "AuthSession.h"

#include <QPdfWriter>
#include <QPainter>
#include <QDir>
#include <QFile>
#include <QTextStream>
#include <QDateTime>
#include <QDate>

namespace mms {

ReportService::ReportRow ReportService::familyRegister(const QString& statusFilter) {
    ReportRow r;
    r.headers << "Family No" << "House Name" << "Ward" << "Area" << "Phone" << "Members" << "Status";

    QString sql = "SELECT f.family_number, f.house_name, f.ward, f.area, f.phone, "
                  "  (SELECT COUNT(*) FROM members m WHERE m.family_id = f.id) AS mc, f.status "
                  "FROM families f";
    QVariantList params;
    if (!statusFilter.isEmpty()) { sql += " WHERE f.status = ?"; params << statusFilter; }
    sql += " ORDER BY f.family_number";

    QSqlQuery q = Database::instance().execute(sql, params);
    while (q.next()) {
        r.addRow({ q.value(0), q.value(1), q.value(2), q.value(3),
                   q.value(4), q.value(5), q.value(6) });
    }
    return r;
}

ReportService::ReportRow ReportService::memberRegister(const QString& statusFilter) {
    ReportRow r;
    r.headers << "Code" << "Name" << "Gender" << "Age" << "Mobile" << "Family No" << "House Name";

    QString sql = "SELECT m.member_code, m.name, m.gender, m.age, m.mobile, "
                  "f.family_number, f.house_name FROM members m "
                  "LEFT JOIN families f ON f.id = m.family_id";
    QVariantList params;
    if (!statusFilter.isEmpty()) { sql += " WHERE m.status = ?"; params << statusFilter; }
    sql += " ORDER BY m.name";

    QSqlQuery q = Database::instance().execute(sql, params);
    while (q.next()) {
        r.addRow({ q.value(0), q.value(1), q.value(2), q.value(3),
                   q.value(4), q.value(5), q.value(6) });
    }
    return r;
}

ReportService::ReportRow ReportService::activeMembers() {
    return memberRegister("Active");
}

ReportService::ReportRow ReportService::familyDirectory() {
    ReportRow r;
    r.headers << "Family No" << "House Name" << "Head" << "Phone" << "Address" << "Ward";

    QSqlQuery q = Database::instance().execute(
        "SELECT f.family_number, f.house_name, "
        "  (SELECT name FROM members m WHERE m.family_id = f.id AND m.is_head = 1 LIMIT 1) AS head, "
        "f.phone, f.address, f.ward FROM families f "
        "WHERE f.status = 'Active' ORDER BY f.family_number");
    while (q.next()) {
        r.addRow({ q.value(0), q.value(1), q.value(2), q.value(3), q.value(4), q.value(5) });
    }
    return r;
}

ReportService::ReportRow ReportService::subscriptionReport(const QString& dateFrom, const QString& dateTo) {
    ReportRow r;
    r.headers << "Receipt" << "Family No" << "Member" << "Plan" << "Amount" << "Paid" << "Date" << "Status";

    QString sql = "SELECT s.receipt_number, f.family_number, m.name, p.name, "
                  "s.amount, s.amount_paid, s.payment_date, s.status "
                  "FROM subscriptions s "
                  "LEFT JOIN families f ON f.id = s.family_id "
                  "LEFT JOIN members m ON m.id = s.member_id "
                  "LEFT JOIN subscription_plans p ON p.id = s.plan_id "
                  "WHERE 1=1";
    QVariantList params;
    if (!dateFrom.isEmpty()) { sql += " AND s.payment_date >= ?"; params << dateFrom; }
    if (!dateTo.isEmpty())   { sql += " AND s.payment_date <= ?"; params << dateTo;   }
    sql += " ORDER BY s.payment_date DESC";

    QSqlQuery q = Database::instance().execute(sql, params);
    while (q.next()) {
        r.addRow({ q.value(0), q.value(1), q.value(2), q.value(3),
                   q.value(4), q.value(5), q.value(6), q.value(7) });
    }
    return r;
}

ReportService::ReportRow ReportService::defaultersReport() {
    ReportRow r;
    r.headers << "Family No" << "House Name" << "Phone" << "Pending Count" << "Due Amount";
    QSqlQuery q = Database::instance().execute("SELECT * FROM v_defaulters ORDER BY due_amount DESC");
    while (q.next()) {
        r.addRow({ q.value("family_number"), q.value("house_name"), q.value("phone"),
                   q.value("pending_count"), q.value("due_amount") });
    }
    return r;
}

ReportService::ReportRow ReportService::donationReport(const QString& dateFrom, const QString& dateTo) {
    ReportRow r;
    r.headers << "Receipt" << "Donor" << "Category" << "Amount" << "Date" << "Purpose";
    QString sql = "SELECT d.receipt_number, d.donor_name, c.name, d.amount, d.donation_date, d.purpose "
                  "FROM donations d LEFT JOIN donation_categories c ON c.id = d.category_id WHERE 1=1";
    QVariantList params;
    if (!dateFrom.isEmpty()) { sql += " AND d.donation_date >= ?"; params << dateFrom; }
    if (!dateTo.isEmpty())   { sql += " AND d.donation_date <= ?"; params << dateTo;   }
    sql += " ORDER BY d.donation_date DESC";

    QSqlQuery q = Database::instance().execute(sql, params);
    while (q.next()) {
        r.addRow({ q.value(0), q.value(1), q.value(2), q.value(3), q.value(4), q.value(5) });
    }
    return r;
}

ReportService::ReportRow ReportService::incomeReport(const QString& dateFrom, const QString& dateTo) {
    ReportRow r;
    r.headers << "Date" << "Account" << "Description" << "Amount" << "Receipt";
    QString sql = "SELECT t.txn_date, la.name, t.description, t.amount, t.receipt_number "
                  "FROM transactions t LEFT JOIN ledger_accounts la ON la.id = t.account_id "
                  "WHERE t.type = 'Income'";
    QVariantList params;
    if (!dateFrom.isEmpty()) { sql += " AND t.txn_date >= ?"; params << dateFrom; }
    if (!dateTo.isEmpty())   { sql += " AND t.txn_date <= ?"; params << dateTo;   }
    sql += " ORDER BY t.txn_date DESC";
    QSqlQuery q = Database::instance().execute(sql, params);
    while (q.next()) {
        r.addRow({ q.value(0), q.value(1), q.value(2), q.value(3), q.value(4) });
    }
    return r;
}

ReportService::ReportRow ReportService::expenseReport(const QString& dateFrom, const QString& dateTo) {
    ReportRow r;
    r.headers << "Date" << "Account" << "Description" << "Amount" << "Reference";
    QString sql = "SELECT t.txn_date, la.name, t.description, t.amount, t.reference "
                  "FROM transactions t LEFT JOIN ledger_accounts la ON la.id = t.account_id "
                  "WHERE t.type = 'Expense'";
    QVariantList params;
    if (!dateFrom.isEmpty()) { sql += " AND t.txn_date >= ?"; params << dateFrom; }
    if (!dateTo.isEmpty())   { sql += " AND t.txn_date <= ?"; params << dateTo;   }
    sql += " ORDER BY t.txn_date DESC";
    QSqlQuery q = Database::instance().execute(sql, params);
    while (q.next()) {
        r.addRow({ q.value(0), q.value(1), q.value(2), q.value(3), q.value(4) });
    }
    return r;
}

ReportService::ReportRow ReportService::cashBookReport(const QString& dateFrom, const QString& dateTo) {
    ReportRow r;
    r.headers << "Date" << "Type" << "Account" << "Description" << "In" << "Out";
    QString sql = "SELECT t.txn_date, t.type, la.name, t.description, t.amount, t.reference "
                  "FROM transactions t LEFT JOIN ledger_accounts la ON la.id = t.account_id WHERE 1=1";
    QVariantList params;
    if (!dateFrom.isEmpty()) { sql += " AND t.txn_date >= ?"; params << dateFrom; }
    if (!dateTo.isEmpty())   { sql += " AND t.txn_date <= ?"; params << dateTo;   }
    sql += " ORDER BY t.txn_date ASC, t.id ASC";
    QSqlQuery q = Database::instance().execute(sql, params);
    while (q.next()) {
        QString type = q.value(1).toString();
        double amount = q.value(4).toDouble();
        r.addRow({ q.value(0), type, q.value(2), q.value(3),
                   type == "Income" ? QVariant(amount) : QVariant(),
                   type == "Expense" ? QVariant(amount) : QVariant() });
    }
    return r;
}

ReportService::ReportRow ReportService::financialSummary(const QString& dateFrom, const QString& dateTo) {
    ReportRow r;
    r.headers << "Type" << "Category" << "Total";

    QSqlQuery q = Database::instance().execute(
        "SELECT la.type, la.category, COALESCE(SUM(t.amount),0) "
        "FROM ledger_accounts la LEFT JOIN transactions t ON t.account_id = la.id "
        "AND t.txn_date >= ? AND t.txn_date <= ? "
        "GROUP BY la.type, la.category ORDER BY la.type, la.category",
        { dateFrom, dateTo });
    while (q.next()) {
        r.addRow({ q.value(0), q.value(1), q.value(2) });
    }
    return r;
}

ReportService::ReportRow ReportService::marriageRegisterReport(const QString& dateFrom, const QString& dateTo) {
    ReportRow r;
    r.headers << "Marriage No" << "Bride" << "Groom" << "Nikah Date" << "Place";
    QString sql = "SELECT marriage_number, bride_name, groom_name, nikah_date, place FROM marriages WHERE 1=1";
    QVariantList params;
    if (!dateFrom.isEmpty()) { sql += " AND nikah_date >= ?"; params << dateFrom; }
    if (!dateTo.isEmpty())   { sql += " AND nikah_date <= ?"; params << dateTo;   }
    sql += " ORDER BY nikah_date DESC";
    QSqlQuery q = Database::instance().execute(sql, params);
    while (q.next()) {
        r.addRow({ q.value(0), q.value(1), q.value(2), q.value(3), q.value(4) });
    }
    return r;
}

ReportService::ReportRow ReportService::deathRegisterReport(const QString& dateFrom, const QString& dateTo) {
    ReportRow r;
    r.headers << "Death No" << "Name" << "Father" << "DOD" << "Burial" << "Cause";
    QString sql = "SELECT death_number, deceased_name, father_name, date_of_death, burial_date, cause_of_death FROM deaths WHERE 1=1";
    QVariantList params;
    if (!dateFrom.isEmpty()) { sql += " AND date_of_death >= ?"; params << dateFrom; }
    if (!dateTo.isEmpty())   { sql += " AND date_of_death <= ?"; params << dateTo;   }
    sql += " ORDER BY date_of_death DESC";
    QSqlQuery q = Database::instance().execute(sql, params);
    while (q.next()) {
        r.addRow({ q.value(0), q.value(1), q.value(2), q.value(3), q.value(4), q.value(5) });
    }
    return r;
}

ReportService::ReportRow ReportService::welfareReport(const QString& dateFrom, const QString& dateTo) {
    ReportRow r;
    r.headers << "Request No" << "Applicant" << "Category" << "Requested" << "Approved" << "Status" << "Date";
    QString sql = "SELECT request_number, applicant_name, category, amount_requested, amount_approved, status, "
                  "  COALESCE(disbursed_date, date(created_at)) AS dt FROM welfare_requests WHERE 1=1";
    QVariantList params;
    if (!dateFrom.isEmpty()) { sql += " AND date(created_at) >= ?"; params << dateFrom; }
    if (!dateTo.isEmpty())   { sql += " AND date(created_at) <= ?"; params << dateTo;   }
    sql += " ORDER BY created_at DESC";
    QSqlQuery q = Database::instance().execute(sql, params);
    while (q.next()) {
        r.addRow({ q.value(0), q.value(1), q.value(2), q.value(3), q.value(4), q.value(5), q.value(6) });
    }
    return r;
}

// ----- Exporters -----

QString ReportService::ensureExportPath(const QString& fileName) {
    QString exportDir = Config::instance().exportDir();
    QDir().mkpath(exportDir);
    return exportDir + "/" + fileName;
}

QString ReportService::exportToCsv(const ReportRow& row, const QString& outputPath) {
    QFile f(outputPath);
    if (!f.open(QIODevice::WriteOnly | QIODevice::Text)) {
        Logger::error("Cannot write CSV: " + outputPath);
        return {};
    }
    QTextStream out(&f);
    out.setEncoding(QStringConverter::Utf8);
    out << row.headers.join(",") << "\n";
    for (int r = 0; r < row.rowCount; ++r) {
        QStringList cells;
        for (int c = 0; c < row.headers.size(); ++c) {
            QString v = row.cell(r, c).toString();
            // Escape CSV: quote if contains comma, quote, or newline
            if (v.contains(',') || v.contains('"') || v.contains('\n')) {
                v.replace("\"", "\"\"");
                v = "\"" + v + "\"";
            }
            cells << v;
        }
        out << cells.join(",") << "\n";
    }
    f.close();
    AuditLogRepository audit;
    auto u = AuthSession::instance().user();
    audit.log(u.id, u.username, "EXPORT", "report", 0, "Exported report to CSV: " + outputPath, "");
    return outputPath;
}

QString ReportService::exportToPdf(const ReportRow& row, const QString& title,
                                   const QString& outputPath,
                                   const QString& dateFrom,
                                   const QString& dateTo) {
    QPdfWriter writer(outputPath);
    writer.setPageSize(QPageSize(QPageSize::A4));
    writer.setResolution(150);
    writer.setPageOrientation(QPageLayout::Portrait);
    writer.setPageMargins(QMarginsF(15, 15, 15, 15), QPageLayout::Millimeter);

    QPainter painter(&writer);
    painter.setRenderHint(QPainter::Antialiasing, true);

    int pageWidth = writer.width();
    int margin = 50;
    int y = margin;

    // Title
    QFont titleFont("Georgia", 18, QFont::Bold);
    painter.setFont(titleFont);
    painter.setPen(QColor("#0a2a5a"));
    painter.drawText(QRect(margin, y, pageWidth - 2*margin, 60), Qt::AlignCenter, title);
    y += 70;

    // Subtitle (date range)
    QFont subFont("Arial", 10);
    painter.setFont(subFont);
    painter.setPen(QColor("#666666"));
    QString subtitle;
    if (!dateFrom.isEmpty() || !dateTo.isEmpty()) {
        subtitle = QString("Period: %1 to %2").arg(dateFrom).arg(dateTo);
    } else {
        subtitle = QString("Generated on %1").arg(QDateTime::currentDateTime().toString("dd MMM yyyy hh:mm"));
    }
    painter.drawText(QRect(margin, y, pageWidth - 2*margin, 30), Qt::AlignCenter, subtitle);
    y += 50;

    // Table
    int cols = row.headers.size();
    if (cols == 0) {
        painter.end();
        return outputPath;
    }
    int tableWidth = pageWidth - 2*margin;
    int colWidth = tableWidth / cols;

    // Header row
    QFont headerFont("Arial", 10, QFont::Bold);
    painter.setFont(headerFont);
    painter.setPen(Qt::white);
    painter.setBrush(QColor("#1a4a8a"));
    painter.drawRect(margin, y, tableWidth, 35);
    painter.setPen(Qt::white);
    for (int c = 0; c < cols; ++c) {
        QRect cellRect(margin + c*colWidth, y, colWidth, 35);
        painter.drawText(cellRect, Qt::AlignVCenter | Qt::AlignLeft,
                         " " + row.headers[c]);
    }
    y += 35;

    // Data rows
    QFont dataFont("Arial", 9);
    painter.setFont(dataFont);
    painter.setPen(QColor("#222222"));

    int rowHeight = 30;
    int pageBottom = writer.height() - margin;
    int rowsThisPage = 0;

    for (int r = 0; r < row.rowCount; ++r) {
        if (y + rowHeight > pageBottom) {
            writer.newPage();
            y = margin;
            // Re-print header on new page
            painter.setFont(headerFont);
            painter.setPen(Qt::white);
            painter.setBrush(QColor("#1a4a8a"));
            painter.drawRect(margin, y, tableWidth, 35);
            for (int c = 0; c < cols; ++c) {
                QRect cellRect(margin + c*colWidth, y, colWidth, 35);
                painter.drawText(cellRect, Qt::AlignVCenter | Qt::AlignLeft, " " + row.headers[c]);
            }
            y += 35;
            painter.setFont(dataFont);
            painter.setPen(QColor("#222222"));
        }

        // Zebra striping
        if (r % 2 == 1) {
            painter.setPen(QColor("#dddddd"));
            painter.setBrush(QColor("#f5f8fc"));
            painter.drawRect(margin, y, tableWidth, rowHeight);
        }

        painter.setPen(QColor("#222222"));
        for (int c = 0; c < cols; ++c) {
            QRect cellRect(margin + c*colWidth + 4, y, colWidth - 8, rowHeight);
            QString val = row.cell(r, c).toString();
            // Truncate long text
            QFontMetrics fm(dataFont);
            if (fm.horizontalAdvance(val) > colWidth - 12) {
                while (val.length() > 1 && fm.horizontalAdvance(val + "...") > colWidth - 12) {
                    val.chop(1);
                }
                val += "...";
            }
            painter.drawText(cellRect, Qt::AlignVCenter | Qt::AlignLeft, val);
        }
        y += rowHeight;
        ++rowsThisPage;
    }

    // Footer
    painter.setFont(QFont("Arial", 8));
    painter.setPen(QColor("#999999"));
    painter.drawText(QRect(margin, writer.height() - 40, pageWidth - 2*margin, 25),
                     Qt::AlignCenter,
                     QString("Total rows: %1 | Generated by Mahallu Management System")
                         .arg(row.rowCount));

    painter.end();

    AuditLogRepository audit;
    auto u = AuthSession::instance().user();
    audit.log(u.id, u.username, "EXPORT", "report", 0,
              QString("Exported report to PDF: %1").arg(outputPath), "");
    return outputPath;
}

QString ReportService::exportToExcel(const ReportRow& row, const QString& title,
                                     const QString& outputPath) {
    // CSV-based Excel (Excel opens CSV natively; for true XLSX use QtXlsx library).
    // We write a UTF-8 BOM + CSV which Excel opens seamlessly.
    QFile f(outputPath);
    if (!f.open(QIODevice::WriteOnly | QIODevice::Text)) {
        Logger::error("Cannot write Excel file: " + outputPath);
        return {};
    }
    f.write("\xEF\xBB\xBF"); // UTF-8 BOM
    QTextStream out(&f);
    out.setEncoding(QStringConverter::Utf8);

    out << title << "\n\n";
    out << row.headers.join(",") << "\n";
    for (int r = 0; r < row.rowCount; ++r) {
        QStringList cells;
        for (int c = 0; c < row.headers.size(); ++c) {
            QString v = row.cell(r, c).toString();
            if (v.contains(',') || v.contains('"') || v.contains('\n')) {
                v.replace("\"", "\"\"");
                v = "\"" + v + "\"";
            }
            cells << v;
        }
        out << cells.join(",") << "\n";
    }
    f.close();

    AuditLogRepository audit;
    auto u = AuthSession::instance().user();
    audit.log(u.id, u.username, "EXPORT", "report", 0,
              QString("Exported report to Excel (CSV): %1").arg(outputPath), "");
    return outputPath;
}

} // namespace mms
