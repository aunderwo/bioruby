module Bio
  class Abi < Chromatogram
    DATA_TYPES = { 1 => 'byte', 2 => 'char', 3 => 'word', 4 => 'short', 5 => 'long',
      7 => 'float', 8 => 'double', 10 => 'date', 11 => 'time', 18 => 'pString',
      19 => 'cString', 12 => 'thumb', 13 => 'bool', 6 => 'rational', 9 => 'BCD',
      14 => 'point', 15 => 'rect', 16 => 'vPoint', 17 => 'vRect', 20 => 'tag',
      128 => 'deltaComp', 256 => 'LZWComp', 384 => 'deltaLZW', 1024 => 'user'} # User defined data types have tags numbers >= 1024

    PACK_TYPES = { 'byte' => 'C', 'char' => 'c', 'word' => 'n', 'short' => 'n', 'long' => 'N',
      'date' => 'nCC', 'time' => 'CCCC', 'pString' => 'CA*', 'cString' => 'Z*',
      'float' => 'g', 'double' => 'G',
      'bool' => 'C', 'thumb' => 'NNCC', 'rational' => 'NN', 'point' => 'nn', 
      'rect' => 'nnnn', 'vPoint' => 'NN', 'vRect' => 'NNNN', 'tag' => 'NN'} # Specifies how to pack each data type
  	
    # header attributes
    attr_accessor :abi, :version, :directory_entries
    
    #sequence attributes
    attr_accessor :sample_title, :dye_mobility

    def initialize(string)
      header = string.slice(0,128)
      # read in header info
      @abi, @version, @directory_tag_name, @directory_tag_number, @directory_element_type, @directory_element_size, @directory_number_of_elements, @directory_data_size, @directory_data_offset, @directory_data_handle= header.unpack("a4 n a4 N n n N N N N")
      @version = @version/100.to_f
      get_directory_entries(string)
      # get sequence
      @sequence = @directory_entries["PBAS"][1].data.map{|char| char.chr.downcase}.join("")
      #get peak indices
      @peak_indices = @directory_entries["PLOC"][1].data
      #get qualities
      @qualities = @directory_entries["PCON"][1].data
      # get sample title
      @sample_title = @directory_entries["SMPL"][1].data
      @directory_entries["PDMF"].size > 2 ? @dye_mobility = @directory_entries["PDMF"][2].data : @dye_mobility = @directory_entries["PDMF"][1].data
      #get trace data
      base_order = @directory_entries["FWO_"][1].data.map{|char| char.chr.downcase}
      (9..12).each do |data_index|
        self.instance_variable_set("@#{base_order[data_index-9]}trace", @directory_entries["DATA"][data_index].data)
      end

    end

    private
    def get_directory_entries(string)
      @directory_entries = Hash.new
      offset = @directory_data_offset
      @directory_number_of_elements.times do
        entry = DirectoryEntry.new
        entry_fields = string.slice(offset, @directory_element_size)
        entry.name, entry.tag_number, entry.element_type, entry.element_size, entry.number_of_elements, entry.data_size, entry.data_offset = entry_fields.unpack("a4 N n n N N N")
        # populate the entry with the data it refers to
        if entry.data_size > 4
          get_entry_data(entry, string)
        else
          get_entry_data(entry, entry_fields)
        end
        if @directory_entries.has_key?(entry.name)
          @directory_entries[entry.name][entry.tag_number] = entry
        else
          @directory_entries[entry.name] = Array.new
          @directory_entries[entry.name][entry.tag_number] = entry
        end
        offset += @directory_element_size
      end
    end
    def get_entry_data(entry, string)
      if entry.data_size > 4
        raw_data = string.slice(entry.data_offset, entry.data_size)
      else
        raw_data = string.slice(20,4)
      end
      if entry.element_type > 1023
        entry.data = "user defined data: not processed as yet by this bioruby module"
      else
        pack_type = PACK_TYPES[DATA_TYPES[entry.element_type]]
        pack_type.match(/\*/) ? unpack_string = pack_type : unpack_string = "#{pack_type}#{entry.number_of_elements}"
        entry.data = raw_data.unpack(unpack_string)
        if pack_type == "CA*" # pascal string where the first byte is a charcter count and should therefore be removed
          entry.data.shift
        end
      end
    end
      
    def method_missing(method_name, tag_number = 1)
      if @directory_entries.has_key?(method_name.to_s)
        return @directory_entries[method_name.to_s][tag_number].data
      else
        return nil
      end
    end
    class DirectoryEntry
      attr_accessor :name, :tag_number, :element_type, :element_size, :number_of_elements, :data_size, :data_offset
      attr_accessor :data
    end
  end
end