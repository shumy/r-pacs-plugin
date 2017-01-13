package pt.ua.ieeta.rpacs.utils

import pt.ua.dicoogle.sdk.DicooglePlugin
import pt.ua.dicoogle.sdk.settings.ConfigurationHolder
import org.eclipse.xtend.lib.annotations.Accessors

abstract class RPacsPluginBase implements DicooglePlugin {
	var enabled = true
	@Accessors var ConfigurationHolder settings
	
	override isEnabled() { return this.enabled }
	override disable() { this.enabled = false; return false }
	override enable() { this.enabled = true; return true }
}