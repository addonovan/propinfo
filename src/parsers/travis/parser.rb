require 'json'

class TravisCountyParser
  def convert_set(input_dir, output_dir)
    data = $file_templates.map do |template|
      file_name = File.join input_dir, template[:name]


      if File.exists? file_name
        puts "Parsing #{file_name} as #{template[:name]}"
        entries = parse_with_structure file_name, template[:structure] do |item|
          yield item
        end
        puts "  (Processed #{entries} records)"
      end
    end

    data.filter
  end

  private

  def parse_with_structure(file, structure)
    file = File.open file, "r"
    count = 0
    file.each_line do |line|
      item = {}
      index = 0
      structure.each do |column|
        header = column[:header].to_sym
        length = column[:length]
        value = line[index...index + length]

        item[header] = if value
                         value.strip
                       end
        index += length
      end

      count += 1
      yield item
    end

    count
  end
end

$base_path = File.join File.dirname(__FILE__), 'structure'
def read_structure(file)
  file_path = File.join $base_path, file
  text = File.read file_path
  JSON.parse text, { symbolize_names: true }
end

$file_templates = [
  { name: 'APPR_HDR.TXT', structure: read_structure('appr_hdr.json') },
  { name: 'PROP.TXT', structure: read_structure('prop.json') },
  { name: 'PROP_ENT.TXT', structure: read_structure('prop_ent.json') },
  { name: 'TOTALS.TXT', structure: read_structure('totals.json') },
  { name: 'ABS_SUBD.TXT', structure: read_structure('abs_subd.json') },
  { name: 'STATE_CD.TXT', structure: read_structure('state_cd.json') },
  { name: 'IMP_INFO.TXT', structure: read_structure('imp_info.json') },
  { name: 'IMP_DET.TXT', structure: read_structure('imp_det.json') },
  { name: 'IMP_ATR.TXT', structure: read_structure('imp_atr.json') },
  { name: 'LAND_DET.TXT', structure: read_structure('land_det.json') },
  { name: 'AGENT.TXT', structure: read_structure('agent.json') },
  { name: 'ARB.TXT', structure: read_structure('arb.json') },
  { name: 'LAWSUIT.TXT', structure: read_structure('lawsuit.json') },
  { name: 'ENTITY.TXT', structure: read_structure('entity.json') },
  { name: 'MOBILE_HOME_INFO.TXT', structure: read_structure('mobile_home_info.json') },
]

tcp = TravisCountyParser.new
value = tcp.convert_set '/tmp/tcad'
puts value
