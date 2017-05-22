package pt.ua.ieeta.rpacs.utils

import com.avaje.ebean.EbeanServer
import com.avaje.ebean.EbeanServerFactory
import com.avaje.ebean.config.DocStoreConfig
import com.avaje.ebean.config.ServerConfig
import java.io.FileInputStream
import java.util.Properties
import org.avaje.datasource.DataSourceConfig
import org.avaje.datasource.pool.ConnectionPool
import pt.ua.ieeta.rpacs.model.Image
import pt.ua.ieeta.rpacs.model.Patient
import pt.ua.ieeta.rpacs.model.Serie
import pt.ua.ieeta.rpacs.model.Study
import pt.ua.ieeta.rpacs.model.ext.Annotation
import pt.ua.ieeta.rpacs.model.ext.Annotator
import pt.ua.ieeta.rpacs.model.ext.Dataset
import pt.ua.ieeta.rpacs.model.ext.Node
import pt.ua.ieeta.rpacs.model.ext.NodeType
import pt.ua.ieeta.rpacs.model.ext.Pointer
import com.avaje.ebean.config.JsonConfig

class DefaultConfig {
	
	static def addClasses(ServerConfig it) {
		addClass(Patient)
		addClass(Study)
		addClass(Serie)
		addClass(Image)
		
		addClass(Annotator)
		addClass(Annotation)
		addClass(Dataset)
		addClass(Pointer)
		addClass(Node)
		addClass(NodeType)
	}
	
	static def ServerConfig config(String sDocUrl, String sDbUrl, String sDriver, String sUsername, String sPassword) {
		val dbConfig = new DataSourceConfig => [
			url = sDbUrl
			driver = sDriver
			username = sUsername
			password = sPassword
			heartbeatSql = 'select 1'
		]
		
		val esConfig = new DocStoreConfig => [
			url = sDocUrl
			active = true
			//generateMapping = true
		]
		
		val sConfig = new ServerConfig => [
			name = 'db'
			currentTenantProvider = [ 'db' ]
			defaultServer = true
			jsonDateTime = JsonConfig.DateTime.ISO8601
			
			addClasses
			
			dataSourceConfig = dbConfig
			dataSource = new ConnectionPool('db', dbConfig)
			
			docStoreConfig = esConfig
		]
		
		return sConfig
	}
	
	def static EbeanServer initServerFromProperties() {
		val props = new Properties
		props.load(new FileInputStream('./ebean.properties'))
		
		val sDocUrl = props.getProperty('db.docstore.url')
		val sDbUrl = props.getProperty('datasource.db.url')
		val sDriver = props.getProperty('datasource.db.driver')
		val sUsername = props.getProperty('datasource.db.username')
		val sPassword = props.getProperty('datasource.db.password')
		
		val sConfig = DefaultConfig.config(sDocUrl, sDbUrl, sDriver, sUsername, sPassword)
		return EbeanServerFactory.create(sConfig)
	}
}