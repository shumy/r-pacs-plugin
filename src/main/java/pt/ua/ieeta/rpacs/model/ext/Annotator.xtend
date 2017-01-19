package pt.ua.ieeta.rpacs.model.ext

import javax.validation.constraints.NotNull
import shy.xhelper.ebean.XEntity

@XEntity
class Annotator {
	@NotNull String name
	@NotNull String alias
}