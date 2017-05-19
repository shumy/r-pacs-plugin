package pt.ua.ieeta.rpacs.cli

import java.io.OutputStream
import java.io.PrintStream
import picocli.CommandLine
import pt.ua.ieeta.rpacs.model.Image
import pt.ua.ieeta.rpacs.utils.DefaultConfig
import pt.ua.ieeta.rpacs.utils.DocSearch

class RPacsCli {
	
	def static void main(String[] args) {
		val OutputStream no = []
		System.setErr(new PrintStream(no))
		
		try {
			val cmd = CommandLine.parse(new RCommand, args)
			if (cmd.help) {
				CommandLine.usage(new RCommand, System.out)
				return
			}
			
			val srv = DefaultConfig.initServerFromProperties
			
			if (cmd.search !== null) {
				val int from = cmd.from ?: 0
				val int size = cmd.size ?: 100
				val results = DocSearch.search(cmd.search, from, size)
				
				var n = 0
				for (it: results) {
					n++
					println('''«n»: {id: «id», uid: «uid», annotations: «annotations.length»}''')
				}
			}
			
			if (cmd.create !== null) {
				if (cmd.create == 'all') {
					srv.docStore.createIndex(Image.INDEX, Image.INDEX)
					println('''Create Index (Image -> «Image.INDEX»)''')
				} else {
					srv.docStore.createIndex(cmd.create, cmd.create)
					println('''Create Index -> «cmd.create»''')
				}
				
				return
			}
			
			if (cmd.drop !== null) {
				if (cmd.drop == 'all') {
					srv.docStore.dropIndex(Image.INDEX)
					println('''Drop Index (Image -> «Image.INDEX»)''')
				} else {
					srv.docStore.dropIndex(cmd.drop)
					println('''Drop Index -> «cmd.drop»''')
				}
				
				return
			}
			
			if (cmd.index !== null) {
				if (cmd.index == 'all') {
					val startTime = System.currentTimeMillis
					srv.docStore.indexAll(Image)
					val endTime   = System.currentTimeMillis
					println('''Indexed (Image -> «Image.INDEX») in «endTime - startTime» ms''')
				}
				
				return
			}
		} catch (Throwable ex) {
			ex.printStackTrace(System.out)
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
	

}