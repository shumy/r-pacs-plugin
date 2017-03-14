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
	//this was introduced in case there is an automatic process for image quality assessment!
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
		
		quality = ImageQuality.UNDEFINED
		local = ImageLocal.UNDEFINED
			
		retinopathy = Retinopathy.UNDEFINED
		maculopathy = Maculopathy.UNDEFINED
		photocoagulation = Photocoagulation.UNDEFINED
	}
	
	@PrePersist @PreUpdate
	def void presetDraft() {
		if (quality === ImageQuality.UNDEFINED || quality === ImageQuality.BAD) {
			local = ImageLocal.UNDEFINED
			retinopathy = Retinopathy.UNDEFINED
		}
		
		if (retinopathy === Retinopathy.UNDEFINED) {
			maculopathy = Maculopathy.UNDEFINED
			photocoagulation = Photocoagulation.UNDEFINED
		}
		
		if (retinopathy === Retinopathy.R0) {
			maculopathy = Maculopathy.M0
		}
		
		draft =
			quality !== ImageQuality.BAD && (
				retinopathy === Retinopathy.UNDEFINED ||
				maculopathy === Maculopathy.UNDEFINED ||
				photocoagulation === Photocoagulation.UNDEFINED
			)
	}
}

enum ImageLocal { UNDEFINED, MACULA, OPTIC_DICS }
enum ImageQuality { UNDEFINED, GOOD, PARTIAL, BAD }

enum Retinopathy { UNDEFINED, R0, R1, R2_M, R2_S, R3 }
enum Maculopathy { UNDEFINED, M0, M1 }
enum Photocoagulation { UNDEFINED, P0, P1, P2 }