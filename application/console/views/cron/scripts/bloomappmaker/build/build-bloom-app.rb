require 'parse-ruby-client'
require 'awesome_print'
require 'optparse'
require 'fileutils'
require 'open3'
require 'set'
require 'csv'
require 'open-uri'
require 'rmagick'
require_relative 'appbuilder-fonts'

def logEntry(textLine)
  puts textLine
  open($logFile, 'a') { |f|
    f.puts textLine
  }
end

def parseOptions()
  cmd_options = {}
  OptionParser.new do |opts|
    opts.banner = 'Usage: build-bloom-app.rb [options]'
    opts.on('-v', '--[no-]verbose', 'Run verbosely') do |v|
      cmd_options[:verbose] = v
    end
  
    opts.on('--spec_id ID', 'Required: Specify the App Specification ID') do |v|
      cmd_options[:specId]= v
    end
  
    opts.on('--font_dir PATH', "Required: Specifies the path of directory containing fonts and font CSV file")  do |v|
      cmd_options[:fontDir]= v
    end
  
    opts.on('--api_key KEY', 'Specify the Parse API Key') do |v|
      cmd_options[:parseApiKey]= v
    end
  
    opts.on('--app_id ID', 'Specify the Parse Application Id') do |v|
      cmd_options[:parseApplicationId]= v
    end
  
    opts.on('--host HOST', "Specify the Parse Host (default: #{$parseHost}") do |v|
      cmd_options[:parseHost]= v
    end
  
    opts.on('--path PATH', "Specify the Parse Path (defaults: #{$parsePath})") do |v|
      cmd_options[:parsePath]= v
    end
  
    opts.on('--dest DEST', "Specifies the path, either full or relative (default: #{$destination}")  do |v|
      cmd_options[:destination]= v
    end
  
    opts.on('--ks KEYSTORE', "Specifies the path of the keystore")  do |v|
      cmd_options[:ks]= v
    end
  
    opts.on('--ksp PASSWORD', "Specifies the password of the keystore")  do |v|
      cmd_options[:ksp]= v
    end
  
    opts.on('--ka KEY', "Specifies the key in the keystore to use to sign the app")  do |v|
      cmd_options[:ka]= v
    end
  
    opts.on('--kap PASSWORD', "Specifies the password of the key")  do |v|
      cmd_options[:kap]= v
    end
  
    opts.on('--vc VERSIONCODE', "Specifies the version code of the app")  do |v|
      cmd_options[:vc]= v
    end
  
  end.parse!
  
  $options.merge!(cmd_options)  
end
def addIconFiles(iconDir)
  icString = ""
  # First download the icon File
  downloadFile = File.join(iconDir, "originalIconFile.png")
  File.open(downloadFile, 'wb') do |fo|
    fo.write open($iconFile).read
  end
  if (File.exist?(downloadFile))
    seventyTwoFile = File.join(iconDir, "seventyTwo.png")
    oneFourFourFile = File.join(iconDir, "oneFourFour.png")
    puts $iconFile
    img = Magick::Image.read($iconFile).first
    seventyTwoImage = img.resize(72, 72)
    seventyTwoImage.write seventyTwoFile
    oneFourFourImage = img.resize(144,144)
    oneFourFourImage.write oneFourFourFile
    icString = " -ic \"#{seventyTwoFile}\" -ic \"#{oneFourFourFile}\""
  else
    logEntry("ERROR Icon file [#{$iconFile}] does not exist")
    exit 255
  end
  return icString
end
def addFontFiles(supportedFonts, row)
  fontName = supportedFonts[row][0]
  (2..5).each do |column|
    bold = ((column == 3) || (column == 5))
    italic = ((column == 4) || (column == 5))
    fontFileName = supportedFonts[row][column]
    if (fontFileName.nil? || fontFileName.empty?)
      #if we got to this routine, all columns should be filled in
      return "unsupported"
    end 
    fontFilePath = File.join($options[:fontDir], fontFileName)
    if (!File.exist?(fontFilePath))
      return "unsupported"
    end
    $newFonts.add_font(fontName, fontFilePath, bold, italic)
  end
  return "added"
end
def findFont(supportedFonts, font)
  fontUrl = "unsupported"
  (1..supportedFonts.count - 1).each do |row|
    if (supportedFonts[row][0] == font)
      fontUrl = supportedFonts[row][0]
      #Check to see if we need to create font xml
      if (!(supportedFonts[row][2].nil? || supportedFonts[row][2].empty?))
        fontUrl = addFontFiles(supportedFonts, row)    
      end
      break
    end
  end
  return fontUrl
end

def get_rabVersionNumber()
  versionCommand = "dpkg -s reading-app-builder | grep 'Version' | awk -F '[ +]' '{print $2}'"
  versionNumber = `#{versionCommand}`
  return versionNumber.strip
end

def makeDestDir(subDirName)
  # Make the destination directory if it doesn't exist
  destDir = File.join(Dir.pwd, $options[:specId], subDirName)
  unless File.directory?(destDir)
    FileUtils.mkdir_p(destDir)
  end
  return destDir
end

def getBooksInApp()
  booksInApps = Parse::Query.new('booksInApp').tap do |q|
    q.eq("app", Parse::Pointer.new({
        "className" => "appSpecification",
        "objectId" => $options[:specId]
     }))
    q.include = "book"
  end.get
  if (booksInApps.length == 0)
    logEntry("ERROR: No books associated with app specification")
    exit 255
  end
  return booksInApps
end

def addFontsInBook(fontSet, bookDir, bookFontFile)
  logEntry("Calling bloom to identify fonts for #{bookDir}")
  getFontCommand = "bloom getfonts --bookpath \"#{bookDir}\" --reportpath \"#{bookFontFile}\""
  cmdStatus = runCommand(getFontCommand)
  if (cmdStatus == 0)   
    File.open(bookFontFile).each do |line|
      logEntry("  Adding font #{line.strip}")
      fontSet.add(line.strip)
    end
  end
  return fontSet
end

def get_fontString(fontSet)
  fontString = " -f \"Andika New Basic\""
  csvFileName = File.join($options[:fontDir], $csvFileName)
  if (File.exist?(csvFileName))
    fonts = CSV.read(csvFileName)
    fontString = ""

    fontSet.each { |font|
      fontEntry = findFont(fonts, font)
      if (fontEntry == "unsupported")
        logEntry("ERROR: Font #{font} is not supported")
        exit 255
      end
      if (fontEntry == "added")
        logEntry("  Font #{font} added")
      else
        logEntry("  Font #{fontEntry} supported")
        fontString = fontString + " -f \"#{fontEntry}\""
     end
    }
    xmlCount = $newFonts.count()
    if ($newFonts.count() > 0 )
      fontXmlFile = File.join($options[:destination], $fontXmlFileName)
      File.write(fontXmlFile, $newFonts.to_xml)
      fontString = fontString + " -f \"#{fontXmlFile}\""
    end
  end
  return fontString  
end

def buildRabCommand(vernacularIsoCode, colorScheme, bookFileList, fontSet, title)
  fontString = get_fontString(fontSet)
  #Set the version number of the app to the current RAB release number
  versionNumber = get_rabVersionNumber()

  iconDir = makeDestDir('icons')
  icString = addIconFiles(iconDir)
  
  project = "#{$projectName}"
  projectDir = File.join(Dir.pwd, $options[:specId])
  keyOptions = "-ks \"#{$options[:ks]}\" -ksp \"#{$options[:ksp]}\" -ka \"#{$options[:ka]}\" -kap \"#{$options[:kap]}\""
  versionOptions = "-vc #{$options[:vc]} -vn #{versionNumber}"
  formattingOptions = "-l #{vernacularIsoCode} #{fontString} -cs \"#{colorScheme}\" "
  projectOptions = "-n \"#{title}\" -p #{project} -ta 22 -fp apk.output=\"#{$options[:destination]}\" -fp app.def=\"#{projectDir}\""
  rabCommand = "reading-app-builder -new -build #{projectOptions} #{formattingOptions} #{icString} #{keyOptions} #{versionOptions} #{bookFileList}"
  logEntry ("Begin building app")
  logEntry ("  App Name: #{title}")
  logEntry ("  Project: #{project}")
  logEntry ("  Version Number: #{versionNumber}")
  logEntry ("  Version Code: #{$options[:vc]}")
  return rabCommand
end

def runCommand(command)
  puts command
  retStatus = 255
  Open3.popen3(command) do |stdout, stderr, status, thread|
    while line=stderr.gets do 
      puts(line) 
    end
    exit_status = thread.value
    retStatus = exit_status.exitstatus
  end
  return retStatus
end

def hydrateAndFindHtmFile(bookDir, vernacularIsoCode)
  logEntry("Calling bloom to prepare #{bookDir}")
  hydrateCommand = "bloom hydrate --bookpath \"#{bookDir}\" --vernacularisocode \"#{vernacularIsoCode}\" --preset \"app\""
  cmdStatus = runCommand(hydrateCommand)
  if (cmdStatus != 0)
    logEntry("ERROR: Bloom hydrate operation failed! Status: #{cmdStatus}")
    exit cmdStatus
  end
  logEntry("  Operation completed successfully")
  # Get the htm file for each book
  htmBooks = Dir["#{bookDir}*.htm"]
  htmBook = htmBooks[0]
  return htmBook
end

def downloadBook(book, destDir)
  bookPtr = book['book']
  baseUrl = bookPtr['baseUrl']
  objectId = book['objectId']
  if (baseUrl != nil)
    # Fix the slash and at symbols to the way they are needed for bloom
    baseUrl.gsub!("%2f", "/")
    baseUrl.gsub!("%40", "@")
    # The title part of the url must be removed before passing it to bloom
    baseUrl = baseUrl.rpartition('/').first
    baseUrl = baseUrl.rpartition('/').first
    logEntry("Calling bloom to download book. URL: #{baseUrl}")
    downloadCommand = "bloom download --url \"#{baseUrl}\" --dest \"#{destDir}\""
    cmdStatus = runCommand(downloadCommand)
    if (cmdStatus != 0)
      logEntry("ERROR: Download failed! Status: #{cmdStatus}")
      exit cmdStatus
    end
    logEntry("  Download operation completed successfully")
  else
    logEntry("ERROR: Base URL for book isn't set")
    exit 255
  end  
end

def checkForRequiredOptions()
  if ($options[:fontDir].empty?)
    logEntry("ERROR: font_dir parameter is required")
    exit 255
  end
  if ($options[:specId].empty?)
    logEntry("ERROR: spec_id parameter is required")
    exit 255
  end
end

def getAppDetails(isoCode)
  appDetails = Parse::Query.new('appDetailsInLanguage').tap do |q|
    q.related_to("details", Parse::Pointer.new({
    "className" => "appSpecification",
    "androidStoreLanguageIso" => "#{isoCode}",
    "objectId" => "#{$options[:specId]}"
    }))
  end.get

  appDetailEntry = appDetails[0]
  if (appDetailEntry.nil?)
    logEntry("ERROR: appDetails not found for app")
    exit 255
  end
  ap appDetailEntry
  return appDetailEntry
end
#use keys below to access main bloom library
#$parseApiKey = 'P6dtPT5Hg8PmBCOxhyN9SPmaJ8W4DcckyW0EZkIx'
#$parseApplicationId = 'R6qNTeumQXjJCMutAJYAwPtip1qBulkFyLefkCE5'

#use keys below to access sandbox
$parseApiKey = 'KZA7c0gAuwTD6kZHyO5iZm0t48RplaU7o3SHLKnj'
$parseApplicationId = 'yrXftBF6mbAuVu3fO6LnhCJiHxZPIdE7gl1DUVGR'

$parseHost = 'api.parse.com'
$parsePath = '/1'
$destination = 'books'
$projectName = ''
$keyStore = "KeyStore"
$keyStorePassword = "password"
$appKey = "Key"
$appKeyPassword = "password"
$appVersionCode = 1
$fontDir = ""
$logFile = ""
$specId = ""
$newFonts = AppBuilderFonts.new
$iconFile = ""

$csvFileName = "Bloom App Maker Fonts.csv"
$fontXmlFileName = "rabFonts.xml"

$options = { :specId => $specId,
             :parseApiKey => $parseApiKey,
             :parseApplicationId => $parseApplicationId,
             :parseHost => $parseHost,
             :parsePath => $parsePath,
             :destination => $destination,
             :ks => $keyStore,
             :ksp => $keyStorePassword,
             :ka => $appKey,
             :kap => $appKeyPassword,
             :vc => $appVersionCode,
             :fontDir => $fontDir}
parseOptions()
puts "host: #{$options[:parseHost]}"
puts "path: #{$options[:parsePath]}"
client = Parse.init :application_id => $options[:parseApplicationId],
               :api_key => $options[:parseApiKey],
               :master_key => nil,
               :quiet => false,
               :host => "#{$options[:parseHost]}",
               :path => "#{$options[:parsePath]}"

#View all appSpecs
=begin
myAppSpecs = Parse::Query.new('appSpecification').get
ap myAppSpecs
puts "App Details"
myAppDetails = Parse::Query.new('appDetailsInLanguage').get
ap myAppDetails
puts "all books"
myAllBooks = Parse::Query.new('booksInApp').get
ap myAllBooks
=end

# Make the destination directory if it doesn't exist
unless File.directory?($options[:destination])
  FileUtils.mkdir_p($options[:destination])
end
iconDir = makeDestDir('icons')

destDir = makeDestDir('books')
bookFontFile = File.join(destDir, 'fonts')

logDir = makeDestDir('log')
$logFile = File.join(logDir, 'appbuildlog.txt')
open($logFile, 'w') { |f|
  f.puts "Start build of #{$options[:appName]} app"
}
checkForRequiredOptions()

# Get the app specification entry for the id entered
logEntry("Retrieving appSpecification ID: #{$options[:specId]}")
appSpecifications = Parse::Query.new('appSpecification').eq('objectId', $options[:specId]).get
ap appSpecifications

appSpecification = appSpecifications[0]
if (appSpecification.nil?)
  logEntry("ERROR: appSpecification ID not found")
  exit 255
end
vernacularIsoCode = appSpecification['bookVernacularLanguageIso']
if (vernacularIsoCode.nil?)
  logEntry("WARNING: ISO Code not found in App Specification Entry, defaulting to en")
  vernacularIsoCode = "en"
end
colorScheme = appSpecification['colorScheme']
if (colorScheme.nil?)
  logEntry("WARNING: Color Scheme not found in App Specification Entry, defaulting to Dark Blue")
  colorScheme = "Dark Blue"
end
$projectName = appSpecification['packageName']
if ($projectName.nil?)
  logEntry("ERROR: Package name not found in App Specification Entry")
  exit 255
end
$iconFile = appSpecification['icon1024x1024']
if ($iconFile.nil?)
  logEntry("ERROR: Icon File not found in App Specification Entry")
end
defaultStoreLanguageIso = appSpecification['defaultStoreLanguageIso']
storeDetails = getAppDetails(defaultStoreLanguageIso)
appTitle = storeDetails['title']
if (appTitle.nil?)
  logEntry("ERROR: App Title not found in App Details")
  exit 255
end

logEntry("appSpecification retrieved. Title: [#{appTitle}] Color Scheme: [#{colorScheme}] ISO Code: [#{vernacularIsoCode}] Icon: [#{$iconFile}] Project Name: [#{$projectName}]")

# Retrieve the books associated with the app specifcation id
booksInApps = getBooksInApp()

# Download each book listing retrieved above
booksInApps.each { |book|
  downloadBook(book, destDir)
}

# Do a bloom hydrate for each directory downloaded
# Also find the htm file and add the fonts in the book to the list of fonts for the app
searchDir = File.join(destDir, "*/")
bookDirList = Dir[searchDir]
bookFileList = ""
fontSet = Set.new
bookDirList.each { |bookDir|
  htmBook = hydrateAndFindHtmFile(bookDir, vernacularIsoCode)
  bookFileList = bookFileList + " -b \"#{htmBook}\""
  fontSet = addFontsInBook(fontSet, bookDir, bookFontFile)
}

#Build the app
rabCommand = buildRabCommand(vernacularIsoCode, colorScheme, bookFileList, fontSet, appTitle)
cmdStatus = runCommand(rabCommand)
if (cmdStatus == 0)
  logEntry ("App build completed successfully")
else
  logEntry("ERROR: App build returned error! Status : #{cmdStatus}")
end
exit cmdStatus
