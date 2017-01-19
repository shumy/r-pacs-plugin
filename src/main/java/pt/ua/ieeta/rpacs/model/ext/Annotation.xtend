package pt.ua.ieeta.rpacs.model.ext

import com.fasterxml.jackson.annotation.JsonGetter
import javax.persistence.ManyToOne
import javax.validation.constraints.NotNull
import pt.ua.ieeta.rpacs.model.Image
import shy.xhelper.ebean.XEntity

@XEntity
class Annotation {
	
	@ManyToOne
	@NotNull Image image
	@NotNull Annotator annotator
	
	
	@NotNull ImageLocal local
	@NotNull ImageQuality quality
	//@NotNull Integer contrast
	
	@NotNull Retinopathy retinopathy
	@NotNull Maculopathy maculopathy
	@NotNull Photocoagulation photocoagulation
	
	@JsonGetter
	def getHasPatology() { !(retinopathy === Retinopathy.R0) }
}

enum ImageLocal { MACULA, OPTIC_DICS, UNDEFINED }
enum ImageQuality { GOOD, PARTIAL, BAD }

enum Retinopathy { R0, R1, R2, R3 }
enum Maculopathy { M0, M1 }
enum Photocoagulation { P0, P1 }