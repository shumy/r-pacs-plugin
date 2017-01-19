package pt.ua.ieeta.rpacs.model.ext

import javax.persistence.ManyToOne
import javax.validation.constraints.NotNull
import pt.ua.ieeta.rpacs.model.Image
import shy.xhelper.ebean.XEntity

@XEntity
class Lesion {
	
	@ManyToOne
	@NotNull Image image
	
	@ManyToOne
	@NotNull Annotator annotator
	
	
	@NotNull Type type
	@NotNull String geometry //SVG ??
}

enum Type { MICROANEURYSMS, HEMORRHAGES, HARD_EXUDATES, SOFT_EXUDATES, NEOVASCULARIZATIONS }