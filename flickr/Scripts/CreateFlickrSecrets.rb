#!/usr/bin/ruby
# https://medium.com/@nunogonalves/handling-secrets-in-ios-open-source-projects-b5a212f4e28c

file_content = <<-CREDS_FILE_STRING
struct FlickrSecrets {
    static let FlickrApiKey = "#{ENV['FLICKR_API_KEY']}"
}
CREDS_FILE_STRING

file = File.new("./flickr/Build/FlickrSecrets.swift", "w")
file.puts(file_content)
file.close

