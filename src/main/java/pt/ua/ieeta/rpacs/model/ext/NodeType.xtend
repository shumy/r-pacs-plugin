package pt.ua.ieeta.rpacs.model.ext

import javax.persistence.Column
import javax.validation.constraints.NotNull
import shy.xhelper.ebean.XEntity

@XEntity
class NodeType {
	
	@Column(unique=true)
	@NotNull String name
	
	//TODO: JSON Schema or other schema validation? Future developments can use this like a google form schemas.
	//TODO: we can apply a rule engine here?
}