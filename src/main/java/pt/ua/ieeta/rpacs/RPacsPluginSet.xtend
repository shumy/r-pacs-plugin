package pt.ua.ieeta.rpacs

import com.avaje.ebean.EbeanServerFactory
import com.avaje.ebean.config.ServerConfig
import net.xeoh.plugins.base.annotations.PluginImplementation
import org.eclipse.xtend.lib.annotations.Accessors
import org.slf4j.LoggerFactory
import pt.ua.dicoogle.sdk.PluginBase
import pt.ua.dicoogle.sdk.settings.ConfigurationHolder
import pt.ua.ieeta.rpacs.utils.DefaultConfig

import static pt.ua.ieeta.rpacs.utils.ClassLoaderRunner.*

@PluginImplementation
class RPacsPluginSet extends PluginBase {
	static val logger = LoggerFactory.getLogger(RPacsPluginSet)
	
	@Accessors val name = 'r-pacs'
	
	override setSettings(ConfigurationHolder xmlSettings) {
		logger.info('R-PACS PluginSet -> Reading Settings')
		this.settings = xmlSettings
		
		//with settings.configuration
		val it = settings.configuration
			val sDocUrl = getString('docUrl')
			val sDbUrl = getString('dbUrl')
			val sDriver = getString('driver')
			val sUsername = getString('username')
			val sPassword = getString('password')
		
		if (sDocUrl === null || sDbUrl === null || sDriver === null || sUsername === null || sPassword === null)
			throw new RuntimeException('R-PACS PluginSet -> Settings ERROR: Please provide (docUrl, dbUrl, driver, username, password) for database!')
		
		logger.info('R-PACS PluginSet -> Using database: {}', sDbUrl)
		logger.info('R-PACS PluginSet -> Using elastic-search: {}', sDocUrl)
		
		runWith(RPacsPluginSet)[
			val sConfig = DefaultConfig.config(sDocUrl, sDbUrl, sDriver, sUsername, sPassword)
			logger.info('R-PACS PluginSet -> Settings OK')
			
			init(sConfig)
		]
	}
	
	def void init(ServerConfig config) {
		logger.info('R-PACS PluginSet -> Initializing')
		EbeanServerFactory.create(config)
		
		indexPlugins.add(new RPacsIndexer)
		queryPlugins.add(new RPacsQuery)
		logger.info('R-PACS PluginSet -> Ready')
	}
	
	override shutdown() { println('R-PACS PluginSet -> Shutdown') }
}