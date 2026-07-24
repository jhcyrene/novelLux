package com.example.novel_lux

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.provider.DocumentsContract
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlin.concurrent.thread

class MainActivity : FlutterActivity() {
    private val channelName = "novellux/epub_directory"
    private val directoryRequestCode = 4517
    private var pendingDirectoryResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "pickDirectory" -> pickDirectory(result)
                "openDirectory" -> {
                    val treeUri = call.arguments as? String
                    if (treeUri == null) {
                        result.error(
                            "invalid_directory",
                            "A directory URI is required.",
                            null,
                        )
                    } else {
                        openDirectory(treeUri, result)
                    }
                }
                "listEpubFiles" -> {
                    val treeUri = call.arguments as? String
                    if (treeUri == null) {
                        result.error(
                            "invalid_directory",
                            "A directory URI is required.",
                            null,
                        )
                    } else {
                        listEpubFiles(treeUri, result)
                    }
                }
                "readEpubFile" -> {
                    val fileUri = call.arguments as? String
                    if (fileUri == null) {
                        result.error(
                            "invalid_file",
                            "A novel file URI is required.",
                            null,
                        )
                    } else {
                        readEpubFile(fileUri, result)
                    }
                }
                "writeEpubFile" -> {
                    @Suppress("UNCHECKED_CAST")
                    val arguments =
                        call.arguments as? Map<String, Any?>
                    val directoryPath =
                        arguments?.get("directoryPath") as? String
                    val name = arguments?.get("name") as? String
                    val bytes = arguments?.get("bytes") as? ByteArray

                    if (
                        directoryPath == null ||
                        name == null ||
                        bytes == null
                    ) {
                        result.error(
                            "invalid_file",
                            "Directory, name, and bytes are required.",
                            null,
                        )
                    } else {
                        writeEpubFile(
                            directoryPath,
                            name,
                            bytes,
                            result,
                        )
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun pickDirectory(result: MethodChannel.Result) {
        if (pendingDirectoryResult != null) {
            result.error(
                "picker_active",
                "The directory picker is already open.",
                null,
            )
            return
        }

        pendingDirectoryResult = result

        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
            addFlags(
                Intent.FLAG_GRANT_READ_URI_PERMISSION or
                    Intent.FLAG_GRANT_WRITE_URI_PERMISSION or
                    Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION,
            )
        }

        startActivityForResult(intent, directoryRequestCode)
    }

    private fun openDirectory(
        treeUriValue: String,
        result: MethodChannel.Result,
    ) {
        try {
            val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
                putExtra(
                    DocumentsContract.EXTRA_INITIAL_URI,
                    Uri.parse(treeUriValue),
                )
                addFlags(
                    Intent.FLAG_GRANT_READ_URI_PERMISSION or
                        Intent.FLAG_GRANT_WRITE_URI_PERMISSION or
                        Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION,
                )
            }

            startActivity(intent)
            result.success(null)
        } catch (error: Exception) {
            result.error(
                "directory_open",
                error.message,
                null,
            )
        }
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(
        requestCode: Int,
        resultCode: Int,
        data: Intent?,
    ) {
        if (requestCode != directoryRequestCode) {
            super.onActivityResult(requestCode, resultCode, data)
            return
        }

        val result = pendingDirectoryResult
        pendingDirectoryResult = null

        if (resultCode != Activity.RESULT_OK || data?.data == null) {
            result?.success(null)
            return
        }

        val treeUri = data.data!!

        try {
            contentResolver.takePersistableUriPermission(
                treeUri,
                Intent.FLAG_GRANT_READ_URI_PERMISSION or
                    Intent.FLAG_GRANT_WRITE_URI_PERMISSION,
            )
            result?.success(treeUri.toString())
        } catch (error: Exception) {
            result?.error(
                "directory_permission",
                error.message,
                null,
            )
        }
    }

    private fun listEpubFiles(
        treeUriValue: String,
        result: MethodChannel.Result,
    ) {
        thread {
            try {
                val treeUri = Uri.parse(treeUriValue)
                val rootUri =
                    DocumentsContract.buildDocumentUriUsingTree(
                        treeUri,
                        DocumentsContract.getTreeDocumentId(treeUri),
                    )
                val books = mutableListOf<Map<String, String>>()

                collectEpubFiles(treeUri, rootUri, books)
                books.sortBy {
                    it["name"]?.lowercase()
                }

                runOnUiThread {
                    result.success(books)
                }
            } catch (error: Exception) {
                runOnUiThread {
                    result.error(
                        "directory_read",
                        error.message,
                        null,
                    )
                }
            }
        }
    }

    private fun collectEpubFiles(
        treeUri: Uri,
        directoryUri: Uri,
        books: MutableList<Map<String, String>>,
    ) {
        val childrenUri =
            DocumentsContract.buildChildDocumentsUriUsingTree(
                treeUri,
                DocumentsContract.getDocumentId(directoryUri),
            )
        val projection = arrayOf(
            DocumentsContract.Document.COLUMN_DOCUMENT_ID,
            DocumentsContract.Document.COLUMN_DISPLAY_NAME,
            DocumentsContract.Document.COLUMN_MIME_TYPE,
        )

        contentResolver.query(
            childrenUri,
            projection,
            null,
            null,
            null,
        )?.use { cursor ->
            val idColumn = cursor.getColumnIndexOrThrow(
                DocumentsContract.Document.COLUMN_DOCUMENT_ID,
            )
            val nameColumn = cursor.getColumnIndexOrThrow(
                DocumentsContract.Document.COLUMN_DISPLAY_NAME,
            )
            val typeColumn = cursor.getColumnIndexOrThrow(
                DocumentsContract.Document.COLUMN_MIME_TYPE,
            )

            while (cursor.moveToNext()) {
                val documentId = cursor.getString(idColumn)
                val name = cursor.getString(nameColumn) ?: continue
                val mimeType = cursor.getString(typeColumn)
                val documentUri =
                    DocumentsContract.buildDocumentUriUsingTree(
                        treeUri,
                        documentId,
                    )

                if (
                    mimeType ==
                    DocumentsContract.Document.MIME_TYPE_DIR
                ) {
                    collectEpubFiles(
                        treeUri,
                        documentUri,
                        books,
                    )
                } else if (
                    name.endsWith(".epub", ignoreCase = true) ||
                    name.endsWith(".html", ignoreCase = true) ||
                    name.endsWith(".htm", ignoreCase = true) ||
                    name.endsWith(".txt", ignoreCase = true)
                ) {
                    books.add(
                        mapOf(
                            "name" to name,
                            "path" to documentUri.toString(),
                        ),
                    )
                }
            }
        }
    }

    private fun readEpubFile(
        fileUriValue: String,
        result: MethodChannel.Result,
    ) {
        thread {
            try {
                val bytes = contentResolver
                    .openInputStream(Uri.parse(fileUriValue))
                    ?.use { it.readBytes() }
                    ?: throw IllegalStateException(
                        "The linked novel file is unavailable.",
                    )

                runOnUiThread {
                    result.success(bytes)
                }
            } catch (error: Exception) {
                runOnUiThread {
                    result.error(
                        "file_read",
                        error.message,
                        null,
                    )
                }
            }
        }
    }

    private fun writeEpubFile(
        treeUriValue: String,
        requestedName: String,
        bytes: ByteArray,
        result: MethodChannel.Result,
    ) {
        thread {
            try {
                val treeUri = Uri.parse(treeUriValue)
                val rootUri =
                    DocumentsContract.buildDocumentUriUsingTree(
                        treeUri,
                        DocumentsContract.getTreeDocumentId(treeUri),
                    )
                val safeName = requestedName
                    .substringAfterLast('/')
                    .substringAfterLast('\\')
                val mimeType = when (
                    safeName.substringAfterLast('.', "").lowercase()
                ) {
                    "epub" -> "application/epub+zip"
                    "html", "htm" -> "text/html"
                    "txt" -> "text/plain"
                    else -> throw IllegalArgumentException(
                        "Only EPUB, HTML, and TXT files are supported.",
                    )
                }
                val fileUri = DocumentsContract.createDocument(
                    contentResolver,
                    rootUri,
                    mimeType,
                    safeName,
                ) ?: throw IllegalStateException(
                    "The novel file could not be created.",
                )

                contentResolver.openOutputStream(
                    fileUri,
                    "w",
                )?.use {
                    it.write(bytes)
                    it.flush()
                } ?: throw IllegalStateException(
                    "The novel file could not be written.",
                )

                runOnUiThread {
                    result.success(fileUri.toString())
                }
            } catch (error: Exception) {
                runOnUiThread {
                    result.error(
                        "file_write",
                        error.message,
                        null,
                    )
                }
            }
        }
    }
}
