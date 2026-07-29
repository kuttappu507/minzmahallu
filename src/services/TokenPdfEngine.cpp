#include "TokenPdfEngine.h"
#include "../core/Logger.h"
#include <QPrintDialog>
#include <QFileDialog>

namespace mms {

// Convert mm to painter units (dots) for current device
static qreal mmToPx(qreal mm, QPaintDevice* device) {
    return mm * device->logicalDpiX() / 25.4;
}

TokenPdfEngine::TokenPdfEngine(QObject* parent) : QObject(parent) {}

bool TokenPdfEngine::generateTokenSheet(const TokenEvent& event, const QList<TokenAssignment>& assignments,
                                        const QString& outputPath, QString* err) {
    QPrinter printer(QPrinter::HighResolution);
    printer.setOutputFormat(QPrinter::PdfFormat);
    printer.setOutputFileName(outputPath);
    printer.setPageSize(QPageSize(QPageSize::A4));
    printer.setPageOrientation(QPageLayout::Portrait);
    printer.setPageMargins(QMarginsF(10, 10, 10, 10), QPageLayout::Millimeter);

    QPainter painter(&printer);
    if (!painter.isActive()) {
        if (err) *err = "Failed to open PDF for writing";
        return false;
    }
    drawTokenSheet(painter, event, assignments, &printer);
    painter.end();
    return true;
}

bool TokenPdfEngine::generateCollectionSheet(const TokenEvent& event, const QList<TokenAssignment>& assignments,
                                             const QString& outputPath, QString* err) {
    QPrinter printer(QPrinter::HighResolution);
    printer.setOutputFormat(QPrinter::PdfFormat);
    printer.setOutputFileName(outputPath);
    printer.setPageSize(QPageSize(QPageSize::A4));
    printer.setPageOrientation(QPageLayout::Portrait);
    printer.setPageMargins(QMarginsF(10, 10, 10, 10), QPageLayout::Millimeter);

    QPainter painter(&printer);
    if (!painter.isActive()) {
        if (err) *err = "Failed to open PDF for writing";
        return false;
    }
    int rowsPerPage = 25;
    int totalPages = (assignments.size() + rowsPerPage - 1) / rowsPerPage;
    if (totalPages == 0) totalPages = 1;
    int page = 0;
    for (int i = 0; i < assignments.size(); i += rowsPerPage) {
        QList<TokenAssignment> pageItems = assignments.mid(i, rowsPerPage);
        if (page > 0) printer.newPage();
        drawCollectionSheet(painter, event, pageItems, page + 1, totalPages, &printer);
        page++;
    }
    if (page == 0) {
        drawCollectionSheet(painter, event, {}, 1, 1, &printer);
    }
    painter.end();
    return true;
}

bool TokenPdfEngine::printTokenSheet(const TokenEvent& event, const QList<TokenAssignment>& assignments, QString* err) {
    QPrinter printer(QPrinter::HighResolution);
    printer.setPageSize(QPageSize(QPageSize::A4));
    printer.setPageOrientation(QPageLayout::Portrait);
    printer.setPageMargins(QMarginsF(10, 10, 10, 10), QPageLayout::Millimeter);

    QPrintDialog dialog(&printer, nullptr);
    if (dialog.exec() != QDialog::Accepted) return false;

    QPainter painter(&printer);
    if (!painter.isActive()) {
        if (err) *err = "Failed to start print";
        return false;
    }
    drawTokenSheet(painter, event, assignments, &printer);
    painter.end();
    return true;
}

bool TokenPdfEngine::printCollectionSheet(const TokenEvent& event, const QList<TokenAssignment>& assignments, QString* err) {
    QPrinter printer(QPrinter::HighResolution);
    printer.setPageSize(QPageSize(QPageSize::A4));
    printer.setPageOrientation(QPageLayout::Portrait);
    printer.setPageMargins(QMarginsF(10, 10, 10, 10), QPageLayout::Millimeter);

    QPrintDialog dialog(&printer, nullptr);
    if (dialog.exec() != QDialog::Accepted) return false;

    QPainter painter(&printer);
    if (!painter.isActive()) {
        if (err) *err = "Failed to start print";
        return false;
    }
    int rowsPerPage = 25;
    int totalPages = (assignments.size() + rowsPerPage - 1) / rowsPerPage;
    if (totalPages == 0) totalPages = 1;
    int page = 0;
    for (int i = 0; i < assignments.size(); i += rowsPerPage) {
        QList<TokenAssignment> pageItems = assignments.mid(i, rowsPerPage);
        if (page > 0) printer.newPage();
        drawCollectionSheet(painter, event, pageItems, page + 1, totalPages, &printer);
        page++;
    }
    if (page == 0) {
        drawCollectionSheet(painter, event, {}, 1, 1, &printer);
    }
    painter.end();
    return true;
}

void TokenPdfEngine::drawTokenSheet(QPainter& painter, const TokenEvent& event,
                                    const QList<TokenAssignment>& assignments, QPrinter* printer) {
    int tokensPerPage = 8;  // 2 columns x 4 rows
    qreal mm = mmToPx(1, printer);

    qreal pageWidth = printer->pageRect(QPrinter::DevicePixel).width();
    qreal pageHeight = printer->pageRect(QPrinter::DevicePixel).height();

    qreal margin = 0;  // margins already set on printer
    qreal availW = pageWidth;
    qreal availH = pageHeight;
    qreal gap = 3 * mm;
    qreal cellW = (availW - gap) / 2;
    qreal cellH = (availH - 3 * gap) / 4;

    int tokenIndex = 0;
    for (int i = 0; i < assignments.size(); i++) {
        if (i > 0 && i % tokensPerPage == 0) {
            printer->newPage();
            tokenIndex = 0;
        }
        int row = (tokenIndex % tokensPerPage) / 2;
        int col = (tokenIndex % tokensPerPage) % 2;
        qreal x = col * (cellW + gap);
        qreal y = row * (cellH + gap);
        QRectF rect(x, y, cellW, cellH);
        drawSingleToken(painter, rect, event, assignments[i], tokenIndex + 1);

        // Draw dashed cutting guide
        if (col == 1 && row < 3) {
            painter.setPen(QPen(QColor("#d1d5db"), 0.3, Qt::DashLine));
            qreal lineY = y + cellH + gap / 2;
            painter.drawLine(QPointF(0, lineY), QPointF(pageWidth, lineY));
        }
        tokenIndex++;
    }
}

void TokenPdfEngine::drawSingleToken(QPainter& painter, const QRectF& rect,
                                     const TokenEvent& event, const TokenAssignment& assignment, int tokenIndex) {
    painter.save();

    qreal mm = mmToPx(1, painter.device());
    QRectF r = rect.adjusted(1, 1, -1, -1);

    // 1. Outer rounded rectangle
    painter.setPen(QPen(QColor("#047857"), 0.5));
    painter.setBrush(Qt::white);
    painter.drawRoundedRect(r, 3 * mm, 3 * mm);

    qreal headerH = 18 * mm;
    qreal codeH = 11 * mm;
    QRectF headerRect(r.left(), r.top(), r.width(), headerH);
    QRectF bodyRect(r.left(), r.top() + headerH, r.width(), r.height() - headerH - codeH);
    QRectF codeRect(r.left(), r.bottom() - codeH, r.width(), codeH);

    // 2. Header band (emerald)
    painter.setPen(Qt::NoPen);
    painter.setBrush(QColor("#10b981"));
    // Cover bottom corners

    QFont font = painter.font();
    font.setBold(true);
    font.setPointSize(8);
    painter.setFont(font);
    painter.setPen(Qt::white);
    painter.drawText(headerRect.adjusted(0, 2*mm, 0, -8*mm), Qt::AlignCenter, "Minz Mahallu");

    font.setPointSize(7);
    painter.setFont(font);
    painter.drawText(headerRect.adjusted(0, 7*mm, 0, -4*mm), Qt::AlignCenter, event.eventName);

    font.setPointSize(6);
    font.setBold(false);
    painter.setFont(font);
    QString dateTime = event.eventDate;
    if (!event.eventTime.isEmpty()) dateTime += "  |  " + event.eventTime;
    painter.drawText(headerRect.adjusted(0, 12*mm, 0, 0), Qt::AlignCenter, dateTime);

    // Separator
    painter.setPen(QPen(QColor("#a7f3d0"), 0.5));
    painter.drawLine(QPointF(r.left(), r.top() + headerH), QPointF(r.right(), r.top() + headerH));

    // 3. Body section
    QRectF leftBody = bodyRect.adjusted(3*mm, 2*mm, -bodyRect.width()*0.4, -2*mm);
    QRectF rightBody = QRectF(bodyRect.right() - bodyRect.width()*0.4 + 2*mm, bodyRect.top() + 2*mm,
                              bodyRect.width()*0.4 - 4*mm, bodyRect.height() - 4*mm);

    // Left side labels
    font.setPointSize(6);
    font.setBold(false);
    painter.setFont(font);
    painter.setPen(QColor("#6b7280"));
    painter.drawText(leftBody.adjusted(0, 0, 0, -leftBody.height()+4*mm), Qt::AlignLeft, "Head:");
    font.setBold(true);
    font.setPointSize(8);
    painter.setFont(font);
    painter.setPen(QColor("#111827"));
    QString headName = assignment.headName;
    if (headName.length() > 20) headName = headName.left(18) + "..";
    painter.drawText(leftBody.adjusted(0, 4*mm, 0, -leftBody.height()+9*mm), Qt::AlignLeft, headName);

    font.setBold(false);
    font.setPointSize(6);
    painter.setFont(font);
    painter.setPen(QColor("#6b7280"));
    painter.drawText(leftBody.adjusted(0, 9*mm, 0, -leftBody.height()+13*mm), Qt::AlignLeft, "House:");
    font.setBold(true);
    font.setPointSize(7);
    painter.setFont(font);
    painter.setPen(QColor("#111827"));
    QString houseName = assignment.houseName;
    if (houseName.length() > 20) houseName = houseName.left(18) + "..";
    painter.drawText(leftBody.adjusted(0, 13*mm, 0, -leftBody.height()+17*mm), Qt::AlignLeft, houseName);

    font.setBold(false);
    font.setPointSize(6);
    painter.setFont(font);
    painter.setPen(QColor("#6b7280"));
    painter.drawText(leftBody.adjusted(0, 17*mm, 0, 0), Qt::AlignLeft,
                     "Ward: " + assignment.ward + "  S.No: " + QString("%1").arg(assignment.serialNumber, 3, 10, QChar('0')));

    // Right side - QR code
    QImage qrImg = generateQRCode(formatQRData(event, assignment), (int)(25 * mm));
    QRectF qrRect(rightBody.center().x() - 12.5*mm, rightBody.top(), 25*mm, 25*mm);
    painter.drawImage(qrRect, qrImg);
    font.setPointSize(5);
    painter.setFont(font);
    painter.setPen(QColor("#6b7280"));
    painter.drawText(QRectF(qrRect.left(), qrRect.bottom(), qrRect.width(), 4*mm),
                     Qt::AlignCenter, "Scan for details");

    // 4. Code band (dark slate)
    // Draw code band with dark background (simple rectangle)
    painter.setPen(Qt::NoPen);
    painter.setBrush(QColor("#1e293b"));
    painter.drawRect(codeRect);

    font.setPointSize(5);
    font.setBold(false);
    painter.setFont(font);
    painter.setPen(QColor("#94a3b8"));
    painter.drawText(codeRect.adjusted(0, 1*mm, 0, -7*mm), Qt::AlignCenter, "TOKEN CODE");

    font.setPointSize(18);
    font.setBold(true);
    painter.setFont(font);
    painter.setPen(Qt::white);

    // Draw individual digit boxes
    qreal boxW = 8 * mm;
    qreal boxH = 7 * mm;
    qreal totalBoxW = 4 * boxW + 3 * 2*mm;
    qreal startX = codeRect.center().x() - totalBoxW / 2;
    qreal boxY = codeRect.center().y() - boxH / 2 + 1*mm;
    for (int d = 0; d < 4 && d < assignment.uniqueCode.length(); d++) {
        QRectF box(startX + d * (boxW + 2*mm), boxY, boxW, boxH);
        painter.setPen(QPen(Qt::white, 0.5));
        painter.setBrush(Qt::NoBrush);
        painter.drawRect(box);
        painter.setPen(Qt::white);
        painter.drawText(box, Qt::AlignCenter, QString(assignment.uniqueCode[d]));
    }

    painter.restore();
}

void TokenPdfEngine::drawCollectionSheet(QPainter& painter, const TokenEvent& event,
                                         const QList<TokenAssignment>& page, int pageNum, int totalPages,
                                         QPrinter* printer) {
    painter.save();
    qreal mm = mmToPx(1, printer);
    qreal pageWidth = printer->pageRect(QPrinter::DevicePixel).width();

    // Header
    QFont font = painter.font();
    font.setBold(true);
    font.setPointSize(10);
    painter.setFont(font);
    painter.setPen(QColor("#047857"));
    painter.drawText(QRectF(0, 0, pageWidth, 8*mm), Qt::AlignLeft | Qt::AlignVCenter, "Minz Mahallu");

    font.setPointSize(9);
    painter.setFont(font);
    painter.drawText(QRectF(0, 0, pageWidth, 8*mm), Qt::AlignRight | Qt::AlignVCenter,
                     QString("Page %1 of %2").arg(pageNum).arg(totalPages));

    font.setBold(true);
    font.setPointSize(11);
    painter.setFont(font);
    painter.drawText(QRectF(0, 8*mm, pageWidth, 6*mm), Qt::AlignLeft, "Event: " + event.eventName);

    font.setBold(false);
    font.setPointSize(9);
    painter.setFont(font);
    QString details = "Date: " + event.eventDate;
    if (!event.eventTime.isEmpty()) details += "    Time: " + event.eventTime;
    if (!event.venue.isEmpty()) details += "    Venue: " + event.venue;
    painter.drawText(QRectF(0, 14*mm, pageWidth, 5*mm), Qt::AlignLeft, details);

    // Table header
    qreal tableTop = 22 * mm;
    qreal rowH = 8 * mm;
    qreal colW[] = {12*mm, 60*mm, 55*mm, 25*mm, 38*mm};
    qreal colX[] = {0, colW[0], colW[0]+colW[1], colW[0]+colW[1]+colW[2], colW[0]+colW[1]+colW[2]+colW[3]};

    painter.setPen(Qt::NoPen);
    painter.setBrush(QColor("#047857"));
    painter.drawRect(QRectF(0, tableTop, pageWidth, rowH));

    font.setBold(true);
    font.setPointSize(8);
    painter.setFont(font);
    painter.setPen(Qt::white);

    QStringList headers = {"No", "Head Name", "House Name", "Code", "Collected"};
    for (int c = 0; c < 5; c++) {
        QRectF cellRect(colX[c], tableTop, colW[c], rowH);
        Qt::Alignment align = (c == 0 || c == 3) ? Qt::AlignCenter : Qt::AlignLeft;
        painter.drawText(cellRect.adjusted(2*mm, 0, -2*mm, 0), align | Qt::AlignVCenter, headers[c]);
    }

    // Table rows
    font.setBold(false);
    font.setPointSize(8);
    painter.setFont(font);

    for (int i = 0; i < page.size(); i++) {
        qreal y = tableTop + (i + 1) * rowH;
        // Alternate row colors
        if (i % 2 == 1) {
            painter.setPen(Qt::NoPen);
            painter.setBrush(QColor("#f0fdf4"));
            painter.drawRect(QRectF(0, y, pageWidth, rowH));
        }
        // Row border
        painter.setPen(QPen(QColor("#e5e7eb"), 0.3));
        painter.setBrush(Qt::NoBrush);
        painter.drawLine(QPointF(0, y), QPointF(pageWidth, y));

        const TokenAssignment& a = page[i];
        painter.setPen(QColor("#111827"));

        // No
        painter.drawText(QRectF(colX[0], y, colW[0], rowH), Qt::AlignCenter | Qt::AlignVCenter,
                         QString::number(a.serialNumber));
        // Head Name
        painter.drawText(QRectF(colX[1], y, colW[1], rowH).adjusted(2*mm, 0, -2*mm, 0),
                         Qt::AlignLeft | Qt::AlignVCenter, a.headName);
        // House Name
        painter.drawText(QRectF(colX[2], y, colW[2], rowH).adjusted(2*mm, 0, -2*mm, 0),
                         Qt::AlignLeft | Qt::AlignVCenter, a.houseName);
        // Code (bold monospace)
        font.setBold(true);
        painter.setFont(font);
        painter.drawText(QRectF(colX[3], y, colW[3], rowH), Qt::AlignCenter | Qt::AlignVCenter, a.uniqueCode);
        font.setBold(false);
        painter.setFont(font);
        // Collected checkbox
        qreal cbSize = 6 * mm;
        QRectF cbRect(colX[4] + 2*mm, y + (rowH - cbSize) / 2, cbSize, cbSize);
        painter.setPen(QPen(QColor("#6b7280"), 0.5));
        painter.setBrush(Qt::NoBrush);
        painter.drawRect(cbRect);
        if (a.isCollected) {
            painter.setPen(QPen(QColor("#10b981"), 1.5));
            painter.drawLine(cbRect.topLeft(), cbRect.bottomRight());
            painter.drawLine(cbRect.topRight(), cbRect.bottomLeft());
        }
    }

    // Footer
    qreal footerY = tableTop + (page.size() + 1) * rowH + 5 * mm;
    painter.setPen(QPen(QColor("#e5e7eb"), 0.5));
    painter.drawLine(QPointF(0, footerY), QPointF(pageWidth, footerY));

    font.setPointSize(8);
    painter.setFont(font);
    painter.setPen(QColor("#6b7280"));
    int collected = 0;
    for (const auto& a : page) if (a.isCollected) collected++;
    painter.drawText(QRectF(0, footerY, pageWidth, 5*mm), Qt::AlignLeft,
                     QString("Total: %1    Collected: %2    Pending: %3")
                         .arg(page.size()).arg(collected).arg(page.size() - collected));
    painter.drawText(QRectF(0, footerY + 5*mm, pageWidth, 5*mm), Qt::AlignLeft,
                     "Verified by: _______________________  Date: ___________");

    painter.restore();
}

QImage TokenPdfEngine::generateQRCode(const QString& data, int sizePx) {
    // For production use, integrate libqrencode or QZXing for proper ISO 18004 QR codes.
    // Current implementation draws a visual identifier pattern for printed tokens.
    QImage img(sizePx, sizePx, QImage::Format_ARGB32);
    img.fill(Qt::white);
    QPainter p(&img);
    p.setRenderHint(QPainter::Antialiasing, false);

    int gridSize = 8;
    int cellSize = sizePx / gridSize;

    // Encode data as simple binary pattern
    QByteArray bytes = data.toUtf8();
    quint32 hash = 0;
    for (char c : bytes) {
        hash = hash * 31 + c;
    }

    // Draw finder pattern (top-left 3x3)
    p.setBrush(Qt::black);
    p.setPen(Qt::NoPen);
    p.drawRect(0, 0, cellSize * 3, cellSize * 3);
    p.setBrush(Qt::white);
    p.drawRect(cellSize, cellSize, cellSize, cellSize);

    // Encode 4-digit code in binary on right side
    QString code = data.section("CODE:", 1, 1).section(" ", 0, 0).trimmed();
    if (code.length() >= 4) {
        p.setBrush(Qt::black);
        for (int d = 0; d < 4; d++) {
            int digit = code.mid(d, 1).toInt();
            for (int b = 0; b < 4; b++) {
                if (digit & (1 << b)) {
                    int x = (4 + b) * cellSize;
                    int y = d * cellSize;
                    p.drawRect(x, y, cellSize, cellSize);
                }
            }
        }
    }

    // Bottom rows: hash-based pattern
    p.setBrush(Qt::black);
    for (int row = 4; row < gridSize; row++) {
        for (int col = 0; col < gridSize; col++) {
            if ((hash >> ((row * gridSize + col) % 32)) & 1) {
                p.drawRect(col * cellSize, row * cellSize, cellSize, cellSize);
            }
        }
    }

    return img;
}

QString TokenPdfEngine::formatQRData(const TokenEvent& event, const TokenAssignment& assignment) {
    return QString("EVENT:%1 CODE:%2 FAMILY:%3")
        .arg(event.id).arg(assignment.uniqueCode).arg(assignment.familyId);
}

} // namespace mms
