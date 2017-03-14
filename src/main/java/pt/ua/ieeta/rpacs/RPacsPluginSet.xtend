package pt.ua.ieeta.rpacs

import com.avaje.ebean.EbeanServerFactory
import com.avaje.ebean.config.ServerConfig
import net.xeoh.plugins.base.annotations.PluginImplementation
import org.avaje.datasource.DataSourceConfig
import org.avaje.datasource.pool.ConnectionPool
import org.eclipse.xtend.lib.annotations.Accessors
import org.slf4j.LoggerFactory
import pt.ua.dicoogle.sdk.PluginBase
import pt.ua.dicoogle.sdk.settings.ConfigurationHolder
import pt.ua.ieeta.rpacs.model.Image
import pt.ua.ieeta.rpacs.model.Patient
import pt.ua.ieeta.rpacs.model.Serie
import pt.ua.ieeta.rpacs.model.Study

import static pt.ua.ieeta.rpacs.utils.ClassLoaderRunner.*
import pt.ua.ieeta.rpacs.model.ext.Annotator
import pt.ua.ieeta.rpacs.model.ext.Annotation
import pt.ua.ieeta.rpacs.model.ext.Lesion
import pt.ua.ieeta.rpacs.model.ext.Dataset

@PluginImplementation
class RPacsPluginSet extends PluginBase {
	static val logger = LoggerFactory.getLogger(RPacsPluginSet)
	
	@Accessors val name = 'r-pacs'
	
	override setSettings(ConfigurationHolder xmlSettings) {
		logger.info('R-PACS PluginSet -> Reading Settings')
		this.settings = xmlSettings
		
		//with settings.configuration
		val it = settings.configuration
			val sUrl = getString('url')
			val sDriver = getString('driver')
			val sUsername = getString('username')
			val sPassword = getString('password')
		
		if (sUrl === null || sDriver === null || sUsername === null || sPassword === null)
			throw new RuntimeException('R-PACS PluginSet -> Settings ERROR: Please provide (url, driver, username, password) for database!')
		
		logger.info('R-PACS PluginSet -> Using datasource: {}', sUrl)
		val dsConfig = new DataSourceConfig => [
			url = sUrl
			driver = sDriver
			username = sUsername
			password = sPassword
		]
		
		val sConfig = new ServerConfig => [
			defaultServer = true
			addClass(Patient)
			addClass(Study)
			addClass(Serie)
			addClass(Image)
			
			addClass(Annotator)
			addClass(Annotation)
			addClass(Lesion)
			addClass(Dataset)
			
			//force Driver class load here to solve some dicoogle classLoader issues!
			runWith(RPacsPluginSet)[
				dataSourceConfig = dsConfig
				dataSource = new ConnectionPool('db', dsConfig)
			]
		]
		
		logger.info('R-PACS PluginSet -> Settings OK')
		init(sUrl, sConfig)
	}
	
	def void init(String url, ServerConfig config) {
		logger.info('R-PACS PluginSet -> Initializing')
		EbeanServerFactory.create(config)
		
		indexPlugins.add(new RPacsIndexer)
		queryPlugins.add(new RPacsQuery(url))
		logger.info('R-PACS PluginSet -> Ready')
	}
	
	override shutdown() { println('R-PACS PluginSet -> Shutdown') }
}