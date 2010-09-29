module AssetsHelper
  def improved_small_thumbnail(asset)
    st = small_thumbnail(asset)
    return st if st

    "ico_#{asset.type}.png"
  end
  
  def small_thumbnail(asset)
    role = get_role(asset, "small_thumbnail")
    location = role && role["locations"].first
    location && location["file_url"]
  end

  def thumbnail(asset)
    role = get_role(asset, "thumbnail")
    location = role && role["locations"].first
    location && location["file_url"]
  end

  def duration(asset)
    if role = get_role(asset, "original_content")
      duration = role["duration"].to_i
      "#{duration / 60}:#{duration % 60}"
    end
  end

  def contents(asset)
    if role = get_role(asset, "original_content")
      role["contents"].to_s
    else
      ""
    end
  end

  def get_role(asset, role)
    asset.roles.select {|r| r["name"] == role}.first
  end
end
