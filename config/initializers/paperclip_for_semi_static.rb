# Some apps using semi-static were started with the paperclip gem
# prior to 3.x. This stored the attachments in different place.
# Set the 2.x path and url with the following
Paperclip::Attachment.default_options.merge!(
    :path => ":rails_root/public/system/:attachment/:id/:style/:basename.:extension", 
    :url => "/system/:attachment/:id/:style/:basename.:extension"
)

# Be sure to restart your server when you modify this file.

Paperclip.options[:content_type_mappings] = {
  :mp3 => "application/octet-stream"
}

