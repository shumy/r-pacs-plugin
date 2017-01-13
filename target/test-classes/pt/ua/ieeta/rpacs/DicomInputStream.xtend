package pt.ua.ieeta.rpacs

import java.io.File
import java.io.FileInputStream
import java.io.IOException
import java.io.InputStream
import java.net.URI
import pt.ua.dicoogle.sdk.StorageInputStream

class DicomInputStream implements StorageInputStream {
	val URI uri
	val InputStream stream
	
	new(String fileName) {
		val path = './test-data/' + fileName
		uri = new URI(path)
		
		val file = new File(path)
		stream = new FileInputStream(file)
	}
	
	override getURI() { uri }
	override getInputStream() throws IOException { stream }
	
	override getSize() throws IOException {
		throw new UnsupportedOperationException("TODO: auto-generated method stub")
	}
}