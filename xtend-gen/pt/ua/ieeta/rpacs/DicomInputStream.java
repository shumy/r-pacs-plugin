package pt.ua.ieeta.rpacs;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.URI;
import org.eclipse.xtext.xbase.lib.Exceptions;
import pt.ua.dicoogle.sdk.StorageInputStream;

@SuppressWarnings("all")
public class DicomInputStream implements StorageInputStream {
  private final URI uri;
  
  private final InputStream stream;
  
  public DicomInputStream(final String fileName) {
    try {
      final String path = ("./test-data/" + fileName);
      URI _uRI = new URI(path);
      this.uri = _uRI;
      final File file = new File(path);
      FileInputStream _fileInputStream = new FileInputStream(file);
      this.stream = _fileInputStream;
    } catch (Throwable _e) {
      throw Exceptions.sneakyThrow(_e);
    }
  }
  
  @Override
  public URI getURI() {
    return this.uri;
  }
  
  @Override
  public InputStream getInputStream() throws IOException {
    return this.stream;
  }
  
  @Override
  public long getSize() throws IOException {
    throw new UnsupportedOperationException("TODO: auto-generated method stub");
  }
}
