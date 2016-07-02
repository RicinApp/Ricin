# encoding: UTF-8

def explore (top)
    files = Dir.entries(top)

    vala_files = []

    files.each do |file|
        if file == '.' or file == '..' or file == '.git'
            next
        end

        if file.end_with?('.vala')
            vala_files << file
        elsif File.directory?(top + '/' + file)
            in_subdir = explore(top + '/' + file)
            in_subdir.each do |sub_file|
                vala_files << file + '/' + sub_file
            end
        end
    end
    return vala_files
end

def check (file)
    content = ''
    errors = 0

    open(file,"r:UTF-8") do |f|
        line_num = 0
        in_comm = false
        while line = f.gets

            if line.index(/\*\//) != nil
                in_comm = false
                line = line.gsub(/.*\*\//, '')
            end

            if in_comm
                line_num += 1
                next
            end

            if line.index(/\/\*/) != nil
                in_comm = true
                line = line.gsub(/.*\/\*/, '')
            end

            # removing comments
            line = line.gsub(/\/\/.*/, '')
            content += line
            line_num += 1
            # don't use as
            if line.include?(' as ')
                puts file + ':' + line_num.to_s + ': Avoid using keyword "as".'
                errors += 1
            end

            #capitals const
            const_re = /const [[:graph:]]* (?<name>[[:graph:]]*)/
            res = const_re.match(line)
            if not res == nil
                name = res[1]
                maj_name = name.upcase
                if name != maj_name
                    puts file + ':' + line_num.to_s + ': Constant ' + name + ' should be named ' + maj_name
                    errors += 1
                end
            end

            # never forget the space before a (. NEVER
            # Ignore _() as used for gettext this way.
            space_re = /(?!\()[[:graph:]]*\(.*\)/
            space_res = space_re.match(line.gsub(/".*"/, ''))
            space_res_s = space_res.to_s
            if not space_res == nil and !space_res_s.include? "_()"
              #  puts space_res.to_s
                puts file + ':' + line_num.to_s + ': Space missing before parenthesis'
                errors += 1
            end
        end
    end

    content = content.gsub(/\/\*.*\*\//su, '')

    # one class or interface by file
    if content.scan(' class ').length + content.scan(' interface ').length > 1
        puts file + ': Too many classes or interfaces defined here.'
        errors += 1
    end

    if errors > 0
        return true
    else
        return false
    end

end

def main

    to_check = explore ('.')

    bad_files = 0

    to_check.each do |vala|
        # puts 'Checking file ' + vala
        if check(vala)
            bad_files += 1
        end
    end

    puts 'bad files : ' + bad_files.to_s + ', total : ' + to_check.length.to_s

    coverage = 100 - (100 * bad_files.to_f / to_check.length.to_f)
    puts 'Coverage : ' + coverage.to_s[0..4]
end

main
