/*
 * libconfig.vapi - vala bindings for libconfig
 * Copyright (C) 2014  Eugenio "g7" Paolantonio and the Semplice Project
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 *
 * Authors:
 *     Eugenio "g7" Paolantonio <me@medesimo.eu>
*/

[CCode (cprefix = "", lower_case_cprefix = "", cheader_filename = "libconfig.h")]
namespace LibConfig {

	[CCode (cname = "int", cprefix = "CONFIG_TYPE_", has_type_id = false)]
	[Flags]
	public enum SettingType {
		NONE = 0,
		GROUP = 1,
		INT = 2,
		INT64 = 3,
		FLOAT = 4,
		STRING = 5,
		BOOL = 6,
		ARRAY = 7,
		LIST = 8
	}

	[CCode (cname = "config_t", destroy_function = "config_destroy", has_type_id = false)]
	public struct Config {

		[CCode (cname = "config_init")]
		public Config();

		[CCode (cname = "config_read_file")]
		public bool read_file(string filename);

		[CCode (cname = "config_write_file")]
		public bool write_file(string filename);

		[CCode (cname = "config_root_setting")]
		public Setting get_root_setting();

		[CCode (cname = "config_lookup")]
		public Setting lookup(string path);

	}

	[CCode (cname = "config_setting_t", free_function = "", has_type_id = false, has_target = false)]
	[Compact]
	public class Setting {

		[CCode (cname = "config_setting_name")]
		public string get_name();

		[CCode (cname = "config_setting_parent")]
		public Setting get_parent();

		[CCode (cname = "config_setting_add")]
		public Setting add(string name, SettingType type);

		[CCode (cname = "config_setting_is_root")]
		public bool is_root();

		[CCode (cname = "config_setting_type")]
		public SettingType get_type();

		[CCode (cname = "config_setting_get_int")]
		public int get_int();

		[CCode (cname = "config_setting_get_int64")]
		public int64 get_int64();

		[CCode (cname = "config_setting_get_float")]
		public float get_float();

		[CCode (cname = "config_setting_get_bool")]
		public bool get_bool();

		[CCode (cname = "config_setting_get_string")]
		public string get_string();

		[CCode (cname = "config_setting_set_int")]
		public bool set_int(int val);

		[CCode (cname = "config_setting_set_int64")]
		public bool set_int64(int64 val);

		[CCode (cname = "config_setting_set_float")]
		public bool set_float(float val);

		[CCode (cname = "config_setting_set_bool")]
		public bool set_bool(bool val);

		[CCode (cname = "config_setting_set_string")]
		public bool set_string(string val);

	}

}
