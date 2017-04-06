package pt.ua.ieeta.rpacs.utils

import com.avaje.ebean.config.ServerConfig
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
}