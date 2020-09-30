ITEMS_AND_UPDATERS = [
    [/^Aged Brie$/, BrieQualityUpdater.new],
    [/^Backstage passes to a TAFKAL80ETC concert$/, BackstagePassQualityUpdater.new],
    [/^Conjured /, ConjuredItemQualityUpdater.new],
    [/^Sulfuras, Hand of Ragnaros$/, QualityUpdateSkipper.new],
]

def update(items)
    items.each do |item|
      update_one(item)
    end
end

# Example list of items
#
# Item = Struct.new(:name, :best_before_days_left, :quality)
# Items = [
#   Item.new("+5 Dexterity Vest", 10, 20),
#   Item.new("Aged Brie", 2, 0),
#   Item.new("Elixir of the Mongoose", 5, 7),
#   Item.new("Sulfuras, Hand of Ragnaros", 0, 80),
#   Item.new("Backstage passes to a TAFKAL80ETC concert", 15, 20),
#   Item.new("Conjured Mana Cake", 3, 6),
# ]

def update_one(item)
  select_updater_for_item_type(item).update(item)
end

def select_updater_for_item_type(item)
  pair = ITEMS_AND_UPDATERS.detect { |re, updater| re =~ item.name }
  updater = pair ? pair[1] : standard_updater
end

def standard_updater
  @standard_handler ||= StandardQualityUpdater.new
end

class StandardQualityUpdater
  def update(item)
    update_quality(item)
    update_best_before_days_left(item)
  end

  def update_quality(item)
    if item.best_before_days_left <= 0
      adjust_quality(item, -2)
    else
      adjust_quality(item, -1)
    end
  end

  def update_best_before_days_left(item)
    item.best_before_days_left -= 1
  end

  def adjust_quality(item, amount)
    item.quality += amount
    item.quality = 50 if item.quality > 50
    item.quality = 0 if item.quality < 0
  end
end

class BrieQualityUpdater < StandardQualityUpdater
  def update_quality(item)
    if item.best_before_days_left <= 0
      adjust_quality(item, 2)
    else
      adjust_quality(item, 1)
    end
  end
end

class BackstagePassQualityUpdater < StandardQualityUpdater
  def update_quality(item)
    if item.best_before_days_left > 10
      adjust_quality(item, 1)
    elsif item.best_before_days_left > 5
      adjust_quality(item, 2)
    elsif item.best_before_days_left > 0
      adjust_quality(item, 3)
    else
      item.quality = 0
    end
  end
end

class ConjuredItemQualityUpdater < StandardQualityUpdater
  def update_quality(item)
    if item.sell_in <= 0
      adjust_quality(item, -4)
    else
      adjust_quality(item, -2)
    end
  end
end

class QualityUpdateSkipper < StandardQualityUpdater
  def update_quality(item)
  end
  def update_best_before_days_left(item)
  end
end
