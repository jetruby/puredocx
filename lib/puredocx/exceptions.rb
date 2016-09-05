module PureDocx
  FileCreatingError         = Class.new(StandardError)
  ImageReadingError         = Class.new(StandardError)
  NoImageDirectoryPathError = Class.new(StandardError)
  TableColumnsWidthError    = Class.new(StandardError)
  TableColumnsCountError    = Class.new(StandardError)
end
