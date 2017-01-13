package pt.ua.ieeta.rpacs.utils;

import org.eclipse.xtend.lib.annotations.Accessors;
import org.eclipse.xtext.xbase.lib.Pure;
import pt.ua.dicoogle.sdk.DicooglePlugin;
import pt.ua.dicoogle.sdk.settings.ConfigurationHolder;

@SuppressWarnings("all")
public abstract class RPacsPluginBase implements DicooglePlugin {
  private boolean enabled = true;
  
  @Accessors
  private ConfigurationHolder settings;
  
  @Override
  public boolean isEnabled() {
    return this.enabled;
  }
  
  @Override
  public boolean disable() {
    this.enabled = false;
    return false;
  }
  
  @Override
  public boolean enable() {
    this.enabled = true;
    return true;
  }
  
  @Pure
  public ConfigurationHolder getSettings() {
    return this.settings;
  }
  
  public void setSettings(final ConfigurationHolder settings) {
    this.settings = settings;
  }
}
