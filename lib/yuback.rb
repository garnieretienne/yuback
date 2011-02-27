$:.unshift(File.dirname(__FILE__)) unless
$:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

# Yuback is a tool created for backed up web applications fully or partially.
module Yuback
  require 'yuback/exec'
end

