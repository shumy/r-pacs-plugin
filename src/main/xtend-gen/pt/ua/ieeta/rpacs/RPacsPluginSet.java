package pt.ua.ieeta.rpacs;

import com.avaje.ebean.EbeanServerFactory;
import com.avaje.ebean.config.ServerConfig;
import net.xeoh.plugins.base.annotations.PluginImplementation;
import org.apache.commons.configuration.XMLConfiguration;
import org.avaje.datasource.DataSourceConfig;
import org.avaje.datasource.pool.ConnectionPool;
import org.eclipse.xtend.lib.annotations.Accessors;
import org.eclipse.xtext.xbase.lib.InputOutput;
import org.eclipse.xtext.xbase.lib.ObjectExtensions;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure0;
import org.eclipse.xtext.xbase.lib.Procedures.Procedure1;
import org.eclipse.xtext.xbase.lib.Pure;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import pt.ua.dicoogle.sdk.PluginBase;
import pt.ua.dicoogle.sdk.settings.ConfigurationHolder;
import pt.ua.ieeta.rpacs.RPacsIndexer;
import pt.ua.ieeta.rpacs.RPacsQuery;
import pt.ua.ieeta.rpacs.model.Image;
import pt.ua.ieeta.rpacs.model.Patient;
import pt.ua.ieeta.rpacs.model.Serie;
import pt.ua.ieeta.rpacs.model.Study;
import pt.ua.ieeta.rpacs.utils.ClassLoaderRunner;

@PluginImplementation
@SuppressWarnings("all")
public class RPacsPluginSet extends PluginBase {
  private final static Logger logger = LoggerFactory.getLogger(RPacsPluginSet.class);
  
  @Accessors
  private final String name = "r-pacs";
  
  @Override
  public void setSettings(final ConfigurationHolder xmlSettings) {
    RPacsPluginSet.logger.info("R-PACS PluginSet -> Reading Settings");
    this.settings = xmlSettings;
    final XMLConfiguration it = this.settings.getConfiguration();
    final String sUrl = it.getString("url");
    final String sDriver = it.getString("driver");
    final String sUsername = it.getString("username");
    final String sPassword = it.getString("password");
    if (((((sUrl == null) || (sDriver == null)) || (sUsername == null)) || (sPassword == null))) {
      throw new RuntimeException("R-PACS PluginSet -> Settings ERROR: Please provide (url, driver, username, password) for database!");
    }
    RPacsPluginSet.logger.info("R-PACS PluginSet -> Using datasource: {}", sUrl);
    DataSourceConfig _dataSourceConfig = new DataSourceConfig();
    final Procedure1<DataSourceConfig> _function = (DataSourceConfig it_1) -> {
      it_1.setUrl(sUrl);
      it_1.setDriver(sDriver);
      it_1.setUsername(sUsername);
      it_1.setPassword(sPassword);
    };
    final DataSourceConfig dsConfig = ObjectExtensions.<DataSourceConfig>operator_doubleArrow(_dataSourceConfig, _function);
    ServerConfig _serverConfig = new ServerConfig();
    final Procedure1<ServerConfig> _function_1 = (ServerConfig it_1) -> {
      it_1.setDefaultServer(true);
      it_1.addClass(Patient.class);
      it_1.addClass(Study.class);
      it_1.addClass(Serie.class);
      it_1.addClass(Image.class);
      final Procedure0 _function_2 = () -> {
        it_1.setDataSourceConfig(dsConfig);
        ConnectionPool _connectionPool = new ConnectionPool("db", dsConfig);
        it_1.setDataSource(_connectionPool);
      };
      ClassLoaderRunner.runWith(RPacsPluginSet.class, _function_2);
    };
    final ServerConfig sConfig = ObjectExtensions.<ServerConfig>operator_doubleArrow(_serverConfig, _function_1);
    RPacsPluginSet.logger.info("R-PACS PluginSet -> Settings OK");
    this.init(sUrl, sConfig);
  }
  
  public void init(final String url, final ServerConfig config) {
    RPacsPluginSet.logger.info("R-PACS PluginSet -> Initializing");
    EbeanServerFactory.create(config);
    RPacsIndexer _rPacsIndexer = new RPacsIndexer();
    this.indexPlugins.add(_rPacsIndexer);
    RPacsQuery _rPacsQuery = new RPacsQuery(url);
    this.queryPlugins.add(_rPacsQuery);
    RPacsPluginSet.logger.info("R-PACS PluginSet -> Ready");
  }
  
  @Override
  public void shutdown() {
    InputOutput.<String>println("R-PACS PluginSet -> Shutdown");
  }
  
  @Pure
  public String getName() {
    return this.name;
  }
}
