
import QtQuick 2.4
import Ubuntu.Content 1.3
import "MimeTypeMapper.js" as MimeTypeMapper

Item {
    signal exportFromDownloads(var transfer, var mimetypeFilter, bool multiSelect)

    Connections {
        target: ContentHub
        onExportRequested: {
            exportFromDownloads(transfer,
                                MimeTypeMapper.mimeTypeRegexForContentType(transfer.contentType),
                                transfer.selectionType === ContentTransfer.Multiple)

        }
    }
}
