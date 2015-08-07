Plugin.is {
  name "MakeWall"
  version "0.1"
  author "Todd Pickell"
  commands :wall => {
    :usage => "/wall - creates a wall of stone 3 high and 3 wide"
  },
  :dig => {
    :usage => "/dig depth - creates a hole 3 high and 3 wide"
  },
  :gimme => {
    :usage => "/gimme item number - gives you the item corresponding to the number"
  },
  :bridge => {
    :usage => "/bridge length - builds bridge just below feet level to length given"
  },
  :extinguish => {
    :usage => "/extinguish - extinguishes player if they are currently on fire"
  },
  :heal => {
    :usage => "/heal - heals player to max health"
  },
  :nomnom => {
    :usage => "/nomnom - feeds player"
  },
  :dora => {
    :usage => "/dora - resets players air to max and heals them"
  },
  :suitup => {
   :usage => "/suitup - gives player full armor"
  },
  :highbeams => {
    :usage => "/highbeams - grants night vision potion effect"
  }
}

import 'org.bukkit.inventory.ItemStack'
import 'org.bukkit.potion.PotionEffectType'
import 'org.bukkit.potion.PotionEffect'

class MakeWall < RubyPlugin

  def onEnable; print "The MakeWall plugin is enabled."; end
  def onDisable; print "The MakeWall plugin is disabled."; end

  def onCommand(sender, command, label, args)
    case command.name
    when "wall"
      sender.send_message "Building Wall..."
      generate_wall(get_environment(sender.get_location), 1, 2, 1, 3)
      true
    when "dig"
      depth = args.first || 3
      sender.send_message "Digging tunnel #{depth} blocks deep..."
      generate_wall(get_environment(sender.get_location), 0, 1, depth, 3)
      true
    when "gimme"
      item_number = args.first || 50
      quantity = 64
      sender.send_message "Giving item..."
      give_item(sender, item_number, quantity)
      true
    when "bridge"
      length = args.first || 5
      sender.send_message "Building bridge #{length} blocks long..."
      starting_location = sender.get_location
      starting_location.set_y(starting_location.get_y - 1)
      generate_wall(get_environment(starting_location), 1, 1, length, 1)
      true
    when "extinguish"
      sender.send_message "Fire Bad!!!"
      sender.set_fire_ticks 0
      heal(sender)
      true
    when "heal"
      heal(sender)
      true
    when "nomnom"
      sender.send_message "Nom, Nom, Nom..."
      sender.set_food_level 20
      true
    when "dora"
      sender.send_message "Just keep swimming..."
      sender.set_remaining_air(sender.get_maximum_air)
      heal(sender)
      true
    when "suitup"
      sender.send_message "Time to get to work..."
      items = (310..313).each_with_object([]) { |item_number, array| array << ItemStack.new(item_number) }
      sender.get_equipment.set_armor_contents(items)
      true
    when "highbeams"
      sender.send_message "Excuse me sweetie, Your headlights are on..."
      sender.add_potion_effect(PotionEffect.new(PotionEffectType::NIGHT_VISION, 10000, 1))
      true
    else
      false
    end
  end

  def heal(sender)
    sender.send_message "Healing..."
    sender.set_health(sender.get_max_health)
  end

  def give_item(sender, item_number, quantity)
    item_number, quantity = Integer(item_number), Integer(quantity)
    sender.set_item_in_hand(ItemStack.new(item_number, quantity))
  end

  def generate_wall(env, type, offset, depth, heigth)
    depth = Integer(depth)
    width = 3
    heigth.times do |delta_y|
      width.times do |delta_left_right|
        delta_a = delta_left_right - 1
        depth.times do |delta_front|
          delta_b = delta_front + offset
          floored_x = env.fetch(:location).x.floor
          floored_z = env.fetch(:location).z.floor

          block_y = env.fetch(:location).y.floor + delta_y
          block_x, block_z = case env.fetch(:direction)
                             when :north
                               [delta_a + floored_x, (floored_z - delta_b)]
                             when :south
                               [delta_a + floored_x, (floored_z + delta_b)]
                             when :east
                               [(floored_x - delta_b), delta_a + floored_z]
                             when :west
                               [(floored_x + delta_b), delta_a + floored_z]
                             end
          env.fetch(:world).get_block_at(block_x, block_y, block_z).set_type_id(type)
        end
      end
    end
  end

  def get_environment(location)
    { :location => location, :world => location.get_world, :direction => facing_direction(location) }
  end

  def facing_direction(location)
    [:south, :west, :north, :east, :south][(location.yaw / 90.0).round.abs]
  end
end
