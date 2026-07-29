/*
 * ReportService.h - Generate various reports; export to PDF/Excel/CSV
 */
#pragma once

#include <QString>
#include <QVariantList>
#include <QVariantMap>
#include <vector>

namespace mms {

class ReportService {
public:
    struct ReportRow {
        QStringList headers;
        QVariantList cells;       // flattened row data: rows.size() = nRows * headers.size()
        int rowCount = 0;

        void addRow(const QVariantList& r) { cells.append(r); ++rowCount; }
        QVariant cell(int row, int col) const {
            return cells.value(row * headers.size() + col);
        }
    };

    // Available reports
    ReportRow familyRegister(const QString& statusFilter = "Active");
    ReportRow memberRegister(const QString& statusFilter = "Active");
    ReportRow activeMembers();
    ReportRow familyDirectory();
    ReportRow subscriptionReport(const QString& dateFrom, const QString& dateTo);
    ReportRow defaultersReport();
    ReportRow donationReport(const QString& dateFrom, const QString& dateTo);
    ReportRow incomeReport(const QString& dateFrom, const QString& dateTo);
    ReportRow expenseReport(const QString& dateFrom, const QString& dateTo);
    ReportRow cashBookReport(const QString& dateFrom, const QString& dateTo);
    ReportRow financialSummary(const QString& dateFrom, const QString& dateTo);
    ReportRow marriageRegisterReport(const QString& dateFrom, const QString& dateTo);
    ReportRow deathRegisterReport(const QString& dateFrom, const QString& dateTo);
    ReportRow welfareReport(const QString& dateFrom, const QString& dateTo);

    // Exporters
    QString exportToCsv(const ReportRow& row, const QString& outputPath);
    QString exportToPdf(const ReportRow& row, const QString& title,
                        const QString& outputPath,
                        const QString& dateFrom = QString(),
                        const QString& dateTo = QString());
    QString exportToExcel(const ReportRow& row, const QString& title,
                          const QString& outputPath);

    // Helper: ensure export directory exists and return full path
    QString ensureExportPath(const QString& fileName);
};

} // namespace mms
