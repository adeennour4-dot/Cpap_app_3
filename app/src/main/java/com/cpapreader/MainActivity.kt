package com.cpapreader

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Bundle
import android.webkit.WebChromeClient
import android.webkit.WebResourceRequest
import android.webkit.WebView
import android.webkit.WebViewClient
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import java.io.File

class MainActivity : AppCompatActivity() {
    private lateinit var webView: WebView
    private val READ_REQUEST_CODE = 42
    private val PERMISSION_REQUEST_CODE = 100

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        checkPermissions()
        setupWebView()
    }

    private fun checkPermissions() {
        val permissions = arrayOf(
            Manifest.permission.READ_EXTERNAL_STORAGE,
            Manifest.permission.WRITE_EXTERNAL_STORAGE
        )
        
        val notGranted = permissions.filter {
            ContextCompat.checkSelfPermission(this, it) != PackageManager.PERMISSION_GRANTED
        }
        
        if (notGranted.isNotEmpty()) {
            ActivityCompat.requestPermissions(this, notGranted.toTypedArray(), PERMISSION_REQUEST_CODE)
        }
    }

    private fun setupWebView() {
        webView = WebView(this)
        setContentView(webView)
        
        webView.settings.apply {
            javaScriptEnabled = true
            domStorageEnabled = true
            allowFileAccess = true
            allowContentAccess = true
        }
        
        // Add JavaScript interface
        webView.addJavascriptInterface(WebAppInterface(this), "AndroidInterface")
        
        // Load local HTML
        webView.loadUrl("file:///android_asset/web/index.html")
    }

    // Called from JavaScript to open file picker
    fun openFilePicker() {
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        startActivityForResult(intent, READ_REQUEST_CODE)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        
        if (requestCode == READ_REQUEST_CODE && resultCode == RESULT_OK) {
            data?.data?.let { uri ->
                val paths = readDirectory(uri)
                val parsedData = CPAPDataParser.parseMultipleFormats(paths)
                
                // Send data back to JavaScript
                webView.post {
                    webView.evaluateJavascript(
                        "window.receiveCPAPData('${parsedData.replace("'", "\\'")}')",
                        null
                    )
                }
            }
        }
    }

    private fun readDirectory(uri: Uri): List<String> {
        val paths = mutableListOf<String>()
        val docTree = contentResolver.acquireContentProviderClient(uri)?.let {
            // Implementation to traverse SD card files
            // This is simplified - actual implementation would recurse through directories
            it.close()
        }
        return paths
    }
}
