package pt.ua.ieeta.rpacs.model.ext

import com.fasterxml.jackson.annotation.JsonGetter
import javax.persistence.ManyToOne
import javax.validation.constraints.NotNull
import pt.ua.ieeta.rpacs.model.Image
import shy.xhelper.ebean.XEntity
import javax.persistence.PrePersist
import javax.persistence.PreUpdate

@XEntity
class Annotation {
	@NotNull Boolean draft
	
	@ManyToOne
	@NotNull Image image
	
	@ManyToOne
	@NotNull Annotator annotator
	
	@NotNull ImageQuality quality
	@NotNull ImageLocal local
	
	@NotNull Retinopathy retinopathy
	@NotNull Maculopathy maculopathy
	@NotNull Photocoagulation photocoagulation
	
	@JsonGetter
	def getHasPathology() { !(retinopathy === Retinopathy.R0) }
	
	def setDefaults() {
		draft = true
		
		local = ImageLocal.UNDEFINED
		quality = ImageQuality.UNDEFINED
			
		retinopathy = Retinopathy.UNDEFINED
		maculopathy = Maculopathy.UNDEFINED
		photocoagulation = Photocoagulation.UNDEFINED
	}
	
	@PrePersist @PreUpdate
	def void presetDraft() {
		draft = (retinopathy === Retinopathy.UNDEFINED || maculopathy === Maculopathy.UNDEFINED || photocoagulation === Photocoagulation.UNDEFINED)
	}
}

enum ImageLocal { UNDEFINED, MACULA, OPTIC_DICS }
enum ImageQuality { UNDEFINED, GOOD, PARTIAL, BAD }

enum Retinopathy { UNDEFINED, R0, R1, R2, R3 }
enum Maculopathy { UNDEFINED, M0, M1 }
enum Photocoagulation { UNDEFINED, P0, P1 }