package pt.ua.ieeta.rpacs.utils

class ClassLoaderRunner {
	static def void runWith(ClassLoader classLoader, ()=>void clousure) {
		val ctx = Thread.currentThread.contextClassLoader
		try {
			Thread.currentThread.contextClassLoader = classLoader
			clousure.apply
		} catch (Throwable ex) {
			ex.printStackTrace
		} finally {
			Thread.currentThread.contextClassLoader = ctx
		}
	}
	
	static def void runWith(Class<?> loaderFromClass, ()=>void clousure) {
		runWith(loaderFromClass.classLoader, clousure)
	}
}