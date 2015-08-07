Plugin.is {
  name "Example"
  version "0.1"
  author "Todd Pickell"
  commands :jruby => {
          :usage => "/jruby - displays string that lets you know RubyBukkit is working"
      }
}

class Example < RubyPlugin
  def onEnable; print "The Example plugin is enabled."; end
  def onDisable; print "The Example plugin i disabled."; end

  def onCommand(sender, command, label, args)
    if label.downcase == "jruby"
      sender.sendMessage "Jruby Rocks!"
      true
    else
      false
    end
  end
end
