package pt.ua.ieeta.rpacs

import com.avaje.ebean.Ebean
import java.io.BufferedInputStream
import java.net.URI
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.LocalTime
import java.time.format.DateTimeFormatter
import org.dcm4che2.data.Tag
import org.dcm4che2.io.StopTagInputHandler
import org.eclipse.xtend.lib.annotations.Accessors
import org.slf4j.LoggerFactory
import pt.ua.dicoogle.sdk.IndexerInterface
import pt.ua.dicoogle.sdk.StorageInputStream
import pt.ua.dicoogle.sdk.datastructs.IndexReport2
import pt.ua.dicoogle.sdk.task.Task
import pt.ua.ieeta.rpacs.model.Image
import pt.ua.ieeta.rpacs.model.Patient
import pt.ua.ieeta.rpacs.model.Serie
import pt.ua.ieeta.rpacs.model.Study
import pt.ua.ieeta.rpacs.utils.RPacsPluginBase

class RPacsIndexer extends RPacsPluginBase implements IndexerInterface {
	static val logger = LoggerFactory.getLogger(RPacsIndexer)
	
	@Accessors val name = 'r-pacs-indexer'
	
	override handles(URI uri) { return true }
	override unindex(URI uri) { return false }
	
	override index(StorageInputStream file, Object... parameters) {
		index(#[file], parameters)
	}
	
	override index(Iterable<StorageInputStream> streams, Object... objects) {
		new Task[
			val report = new IndexReport2
			streams.forEach[
				if (URI.path.endsWith('.dcm'))
					if (indexStream)
						report.addIndexFile
					else
						report.addError
			]
			
			return report
		]
	}
	
	def boolean indexStream(StorageInputStream storage) {
		logger.info('INDEXING - {}', storage.URI)
		var org.dcm4che2.io.DicomInputStream dicomStream = null
		try {
			dicomStream = new org.dcm4che2.io.DicomInputStream(new BufferedInputStream(storage.inputStream))
			dicomStream.handler = new StopTagInputHandler(Tag.PixelData)
			val dim = dicomStream.readDicomObject
			
			//collect identities...
			val patientID = dim.getString(Tag.PatientID)
			val studyUID = dim.getString(Tag.StudyInstanceUID)
			val serieUID = dim.getString(Tag.SeriesInstanceUID)
			val imageUID = dim.getString(Tag.SOPInstanceUID)
			
			val tx = Ebean.beginTransaction
				//process Image---------------------------------------------------------------
				val eImage = Image.findByUID(imageUID) ?: new Image => [
					uid = imageUID
					number = dim.getInt(Tag.InstanceNumber)
					
					photometric = dim.getString(Tag.PhotometricInterpretation)
					columns = dim.getInt(Tag.Columns)
					rows =  dim.getInt(Tag.Rows)
					laterality = dim.getString(Tag.Laterality)
					uri = storage.URI.toString
				]
				
				if (eImage.id !== null) {
					tx.rollback
					logger.info('ALREADY-INDEXED - ({}, {}, {}, {})', patientID, studyUID, serieUID, imageUID)
					return true
				}
				
				//process Serie---------------------------------------------------------------
				val eSerie = Serie.findByUID(serieUID) ?: new Serie => [
					uid = serieUID
					number = dim.getInt(Tag.SeriesNumber)
					
					description = dim.getString(Tag.SeriesDescription)?:''
					
					val date = getDate(dim.getString(Tag.SeriesDate))
					val time = getTime(dim.getString(Tag.SeriesTime))
					datetime = LocalDateTime.of(date, time)
					
					modality = dim.getString(Tag.Modality)
				]
				
				eSerie.images.add(eImage)
				if (eSerie.id !== null) {
					eSerie.save
					tx.commit
					logger.info('INDEXED - ({}, {}, {}, {})', patientID, studyUID, serieUID, imageUID)
					return true
				}
				
				//process Study---------------------------------------------------------------
				val eStudy = Study.findByUID(studyUID) ?: new Study => [
					uid = studyUID
					sid = dim.getString(Tag.StudyID)
					accessionNumber = dim.getString(Tag.AccessionNumber)
					
					description = dim.getString(Tag.StudyDescription)?:''
					
					val date = getDate(dim.getString(Tag.StudyDate))
					val time = getTime(dim.getString(Tag.StudyTime))
					datetime = LocalDateTime.of(date, time)
					
					institutionName = dim.getString(Tag.InstitutionName)?:''
					institutionAddress = dim.getString(Tag.InstitutionAddress)?:''
				]
				
				eStudy.series.add(eSerie)
				if (eStudy.id !== null) {
					eStudy.save
					tx.commit
					logger.info('INDEXED - ({}, {}, {}, {})', patientID, studyUID, serieUID, imageUID)
					return true
				}
				
				//process Patient-------------------------------------------------------------
				val ePatient = Patient.findByPID(patientID) ?: new Patient => [
					pid = patientID
					it.name = dim.getString(Tag.PatientName)
					sex = dim.getString(Tag.PatientSex)?:'O'
					birthdate = getDate(dim.getString(Tag.PatientBirthDate))
				]
				
				ePatient.studies.add(eStudy)
				ePatient.save
			tx.commit
			logger.info('INDEXED - ({}, {}, {}, {})', patientID, studyUID, serieUID, imageUID)
			return true
		} catch (Exception e) {
			logger.error('INDEX-FAILED - {} {}', storage.URI, e.message)
			Ebean.rollbackTransaction
			e.printStackTrace
			return false
		} finally {
			dicomStream?.close
		}
	}
	
	private def getDate(String dateTxt) {
		var date = dateTxt?:'00000101'
		if (date.length > 8)
			date = date.substring(0, 8)
			
		LocalDate.parse(date, DateTimeFormatter.BASIC_ISO_DATE)
	}
	
	private def getTime(String timeTxt) {
		var time = timeTxt?:'000000'
		if (time.length > 10)
			time = time.substring(0, 10)
		
		return LocalTime.parse(time, DateTimeFormatter.ofPattern('HHmmss[.SSS]'))
	}
}