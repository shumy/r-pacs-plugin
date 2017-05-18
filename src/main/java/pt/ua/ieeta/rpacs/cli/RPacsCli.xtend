package pt.ua.ieeta.rpacs.cli

import com.avaje.ebean.EbeanServer
import com.avaje.ebean.EbeanServerFactory
import java.io.PrintStream
import picocli.CommandLine
import pt.ua.ieeta.rpacs.model.Image
import pt.ua.ieeta.rpacs.utils.DefaultConfig
import java.io.OutputStream

class RPacsCli {
	
	def static void main(String[] args) {
		val OutputStream no = []
		System.setErr(new PrintStream(no))
		
		val cmd = CommandLine.parse(new RCommand, args)
		if (cmd.help) {
			CommandLine.usage(new RCommand, System.out)
			return
		}
		
		if (cmd.drop) {
			val srv = initServer
			
			srv.docStore.dropIndex(Image.INDEX)
			println('''Drop Index (Image -> «Image.INDEX»)''')
			
			return
		}
		
		if (cmd.index) {
			val srv = initServer
			
			
			val startTime = System.currentTimeMillis
			srv.docStore.indexAll(Image)
			val endTime   = System.currentTimeMillis
			println('''Indexed (Image -> «Image.INDEX») in «endTime - startTime» ms''')
			
			return
		}
		
		//index by query:
		/*
		val query = server.find(Product)
			.where
			.ge("whenModified", new Timestamp(since))
			.startsWith("sku", "C")
			.query

			server.docStore.indexByQuery(query, 1000)
		*/
		

	}
	
	def static EbeanServer initServer() {
		val sDocUrl = 'http://127.0.0.1:9200'
		val sDbUrl = 'jdbc:postgresql:r-pacs'
		val sDriver = 'org.postgresql.Driver'
		val sUsername = 'r-pacs'
		val sPassword = 'r-pacs-password'
		
		val sConfig = DefaultConfig.config(sDocUrl, sDbUrl, sDriver, sUsername, sPassword)
		return EbeanServerFactory.create(sConfig)
	}
}