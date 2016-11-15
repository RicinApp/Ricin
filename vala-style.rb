def explore(directory)
    files = Dir.entries(directory) rescue abort("SystemCallError: Directory doesn't exist.")
    vala_files = Array.new

    files.each do |file|
        next if file.start_with?('.', '..', '.git')

        vala_files << file if file.end_with?('.vala')

        subdir = "#{directory}/#{file}"
        if File.directory?(subdir)
            explore(subdir).each { |sub_file| vala_files << "#{file}/#{sub_file}" }
        end
    end

    vala_files
end

def check(file)
    content = String.new
    errors  = 0

    open(file, 'r:UTF-8') do |f|
        line_num = 0
        in_comm  = false

        while line = f.gets

            unless line.index(/\*\//).nil?
                in_comm = false
                line    = line.gsub(/.*\*\//, '')
            end

            line_num += 1 and next if in_comm

            unless line.index(/\/\*/).nil?
                in_comm = true
                line    = line.gsub(/.*\/\*/, '')
            end

            line     = line.gsub(/\/\/.*/, '')
            content  += line
            line_num += 1

            puts "#{file}:#{line_num}: Avoid using keyword \"as\"." and errors += 1 if line.include?(' as ')

            const_re = /const [[:graph:]]* (?<name>[[:graph:]]*)/
            res = const_re.match(line)
            unless res.nil?
                name = res[1]
                unless name == name.upcase
                    puts "#{file}:#{line_num}: Constant #{name} should be named #{name.upcase}"
                    errors += 1
                end
            end

            space_re = /(?!\()[[:graph:]]*\(.*\)/
            space_res = space_re.match(line.gsub(/".*"/, ''))
            unless space_res == nil && !space_res.to_s.include?('_()')
                puts "#{file}:#{line_num}: Space missong before parenthesis."
                errors += 1
            end
        end
    end

    content = content.gsub(/\/\*.*\*\//su, '')

    if (content.scan(' class ').length + content.scan(' interface ').length) > 1
        puts "#{file}: Too many classes or interfaces defined here."
        errors += 1
    end

    errors > 0 ? true : false
end

to_check  = explore('.')
bad_files = 0

to_check.each { |vala| bad_files += 1 if check(vala) }

puts "bad files : #{bad_files}, total : #{to_check.length}"

coverage = 100 - (100 * bad_files.to_f / to_check.length.to_f)
puts "Coverage : #{coverage.to_s[0..4]}"



