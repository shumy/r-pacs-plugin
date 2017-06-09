package pt.ua.ieeta.rpacs

import com.avaje.ebean.EbeanServerFactory
import com.avaje.ebean.config.ServerConfig
import org.junit.Assert
import org.junit.BeforeClass
import org.junit.Test
import pt.ua.ieeta.rpacs.model.Image
import pt.ua.ieeta.rpacs.model.Patient
import pt.ua.ieeta.rpacs.model.Serie
import pt.ua.ieeta.rpacs.model.Study
import com.avaje.ebean.Ebean

class TestRPacsIndexer {
	
	/*@BeforeClass
	static def void setup() {
		EbeanServerFactory.create(new ServerConfig => [
			name = 'db'
			defaultServer = true
			
			loadTestProperties
		])
	}
	
	@Test
	def void indexAndQueryDicomFile() {
		val indexer = new RPacsIndexer
		val query = new RPacsQuery//('h2://mem:tests')
		
		//index files...
		indexer.indexStream(new DicomInputStream('1.2.392.200046.100.3.8.101983.6649.20160504112902.1.1.1.1.dcm'))
		indexer.indexStream(new DicomInputStream('1.2.392.200046.100.3.8.101983.6649.20160504112902.1.1.2.1.dcm'))
		indexer.indexStream(new DicomInputStream('1.2.392.200046.100.3.8.101983.6649.20160504112902.2.1.1.1.dcm'))
		indexer.indexStream(new DicomInputStream('1.2.392.200046.100.3.8.101983.6649.20160504112902.2.1.2.1.dcm'))
		
		Ebean.serverCacheManager.clearAll
		Image.find.byId(1L) => [
			Assert.assertEquals('{"id":1,"version":1,"serie":1,"uid":"1.2.392.200046.100.3.8.101983.6649.20160504112902.1.1.1.1","number":1,"photometric":"RGB","columns":3456,"rows":2304,"laterality":"R","uri":"./test-data/1.2.392.200046.100.3.8.101983.6649.20160504112902.1.1.1.1.dcm"}', toJson)
		]
		
		Serie.find.byId(1L) => [
			Assert.assertEquals('{"id":1,"version":1,"study":1,"uid":"1.2.392.200046.100.3.8.101983.6649.20160504112902.1","number":1,"description":"Color/R","datetime":"2016-05-04T11:29:01","modality":"XC"}', toJson)
		]
		
		Study.find.byId(1L) => [
			Assert.assertEquals('{"id":1,"version":1,"patient":1,"uid":"1.2.826.0.1.3680043.2.1174.4.1.5.1961172","sid":"0000","accessionNumber":"R051961172","description":"Retinografia","datetime":"2016-05-04T11:28:09","institutionName":"Anonymized institution"}', toJson)
		]
		
		Patient.find.byId(1L) => [
			Assert.assertEquals('{"id":1,"version":1,"pid":"250520161135441091","name":"Anonymized patient","sex":"M","birthdate":"1941-10-18","age":75}', toJson)
		]
		
		//serie.study.patient.name:Anonymized AND serie.study.patient.sex:M AND serie.study.accessionNumber:R051961172
		val sResults0 = query.queryText('PatientName:Anonymized and  PatientSex:  M and   AccessionNumber: R051961172  ')
		Assert.assertEquals(4, sResults0.size)
		
		val result0 = sResults0.get(0).extraData
		val result1 = sResults0.get(1).extraData
		val result2 = sResults0.get(2).extraData
		val result3 = sResults0.get(3).extraData
		
		Assert.assertEquals('{InstanceNumber=1, PatientBirthDate=19411018, StudyDescription=Retinografia, StudyInstanceUID=1.2.826.0.1.3680043.2.1174.4.1.5.1961172, SeriesInstanceUID=1.2.392.200046.100.3.8.101983.6649.20160504112902.1, SeriesDescription=Color/R, PhotometricInterpretation=RGB, SeriesNumber=1, Laterality=R, SOPInstanceUID=1.2.392.200046.100.3.8.101983.6649.20160504112902.1.1.1.1, SeriesTime=112901.000, Rows=2304, InstitutionName=Anonymized institution, StudyDate=20160504, Columns=3456, PatientName=Anonymized patient, uri=./test-data/1.2.392.200046.100.3.8.101983.6649.20160504112902.1.1.1.1.dcm, PatientAge=75, StudyTime=112809.000, InstitutionAddress=, StudyID=0000, PatientSex=M, SeriesDate=20160504, PatientID=250520161135441091, AccessionNumber=R051961172, Modality=XC}', result0.toString)
		Assert.assertEquals('{InstanceNumber=2, PatientBirthDate=19411018, StudyDescription=Retinografia, StudyInstanceUID=1.2.826.0.1.3680043.2.1174.4.1.5.1961172, SeriesInstanceUID=1.2.392.200046.100.3.8.101983.6649.20160504112902.1, SeriesDescription=Color/R, PhotometricInterpretation=RGB, SeriesNumber=1, Laterality=R, SOPInstanceUID=1.2.392.200046.100.3.8.101983.6649.20160504112902.1.1.2.1, SeriesTime=112901.000, Rows=2304, InstitutionName=Anonymized institution, StudyDate=20160504, Columns=3456, PatientName=Anonymized patient, uri=./test-data/1.2.392.200046.100.3.8.101983.6649.20160504112902.1.1.2.1.dcm, PatientAge=75, StudyTime=112809.000, InstitutionAddress=, StudyID=0000, PatientSex=M, SeriesDate=20160504, PatientID=250520161135441091, AccessionNumber=R051961172, Modality=XC}', result1.toString)
		Assert.assertEquals('{InstanceNumber=1, PatientBirthDate=19411018, StudyDescription=Retinografia, StudyInstanceUID=1.2.826.0.1.3680043.2.1174.4.1.5.1961172, SeriesInstanceUID=1.2.392.200046.100.3.8.101983.6649.20160504112902.2, SeriesDescription=Color/L, PhotometricInterpretation=RGB, SeriesNumber=2, Laterality=L, SOPInstanceUID=1.2.392.200046.100.3.8.101983.6649.20160504112902.2.1.1.1, SeriesTime=112927.000, Rows=2304, InstitutionName=Anonymized institution, StudyDate=20160504, Columns=3456, PatientName=Anonymized patient, uri=./test-data/1.2.392.200046.100.3.8.101983.6649.20160504112902.2.1.1.1.dcm, PatientAge=75, StudyTime=112809.000, InstitutionAddress=, StudyID=0000, PatientSex=M, SeriesDate=20160504, PatientID=250520161135441091, AccessionNumber=R051961172, Modality=XC}', result2.toString)
		Assert.assertEquals('{InstanceNumber=2, PatientBirthDate=19411018, StudyDescription=Retinografia, StudyInstanceUID=1.2.826.0.1.3680043.2.1174.4.1.5.1961172, SeriesInstanceUID=1.2.392.200046.100.3.8.101983.6649.20160504112902.2, SeriesDescription=Color/L, PhotometricInterpretation=RGB, SeriesNumber=2, Laterality=L, SOPInstanceUID=1.2.392.200046.100.3.8.101983.6649.20160504112902.2.1.2.1, SeriesTime=112927.000, Rows=2304, InstitutionName=Anonymized institution, StudyDate=20160504, Columns=3456, PatientName=Anonymized patient, uri=./test-data/1.2.392.200046.100.3.8.101983.6649.20160504112902.2.1.2.1.dcm, PatientAge=75, StudyTime=112809.000, InstitutionAddress=, StudyID=0000, PatientSex=M, SeriesDate=20160504, PatientID=250520161135441091, AccessionNumber=R051961172, Modality=XC}', result3.toString)
		
		val sResults1 = query.queryText('SOPInstanceUID:1.2.392.200046.100.3.8.101983.6649.20160504112902.1.1.1.1')
		Assert.assertEquals(1, sResults1.size)
		Assert.assertEquals('[./test-data/1.2.392.200046.100.3.8.101983.6649.20160504112902.1.1.1.1.dcm 1.0]', sResults1.toString)
	}*/
}


/*
 	/home/micael/dev/eclipse/work/r-pacs-plugin/test-data
*/