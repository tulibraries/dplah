module DplaUtils

  # The hex digest method is what DPLA uses to generate their ids from our id
  # See KriKri md5_minter
  # https://github.com/dpla/KriKri/blob/e4efe16259c7867731e6042fd13ea9103d09bbe3/lib/krikri/md5_minter.rb#L3-L6
  def self.id_minter(id, prefix='')
    Digest::MD5.hexdigest("#{prefix}#{id}")
  end
end