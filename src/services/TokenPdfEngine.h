#pragma once
#include <QObject>
#include <QPrinter>
#include <QPainter>
#include <QImage>
#include "../models/TokenEvent.h"
#include "../models/TokenAssignment.h"

namespace mms {

class TokenPdfEngine : public QObject {
    Q_OBJECT
public:
    explicit TokenPdfEngine(QObject* parent = nullptr);

    bool generateTokenSheet(const TokenEvent& event, const QList<TokenAssignment>& assignments,
                            const QString& outputPath, QString* err = nullptr);
    bool generateCollectionSheet(const TokenEvent& event, const QList<TokenAssignment>& assignments,
                                 const QString& outputPath, QString* err = nullptr);
    bool printTokenSheet(const TokenEvent& event, const QList<TokenAssignment>& assignments,
                         QString* err = nullptr);
    bool printCollectionSheet(const TokenEvent& event, const QList<TokenAssignment>& assignments,
                              QString* err = nullptr);

private:
    void drawTokenSheet(QPainter& painter, const TokenEvent& event,
                        const QList<TokenAssignment>& assignments, QPrinter* printer);
    void drawSingleToken(QPainter& painter, const QRectF& rect,
                         const TokenEvent& event, const TokenAssignment& assignment, int tokenIndex);
    void drawCollectionSheet(QPainter& painter, const TokenEvent& event,
                             const QList<TokenAssignment>& page, int pageNum, int totalPages,
                             QPrinter* printer);
    QImage generateQRCode(const QString& data, int sizePx);
    QString formatQRData(const TokenEvent& event, const TokenAssignment& assignment);
};

} // namespace mms
