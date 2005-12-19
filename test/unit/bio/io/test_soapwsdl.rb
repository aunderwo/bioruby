#
# test/unit/bio/io/test_soapwsdl.rb - Unit test for SOAP/WSDL
#
#   Copyright (C) 2005 Mitsuteru Nakao <n@bioruby.org>
#
#  This library is free software; you can redistribute it and/or
#  modify it under the terms of the GNU Lesser General Public
#  License as published by the Free Software Foundation; either
#  version 2 of the License, or (at your option) any later version.
#
#  This library is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#  Lesser General Public License for more details.
#
#  You should have received a copy of the GNU Lesser General Public
#  License along with this library; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
#
#  $Id: test_soapwsdl.rb,v 1.1 2005/12/18 17:09:53 nakao Exp $ 
#

require 'pathname'
libpath = Pathname.new(File.join(File.dirname(__FILE__), ['..'] * 4, 'lib')).cleanpath.to_s
$:.unshift(libpath) unless $:.include?(libpath)


require 'test/unit'
require 'bio/io/soapwsdl'

module Bio

class TestSOAPWSDL < Test::Unit::TestCase

  def setup
    @obj = Bio::SOAPWSDL
  end

  def test_methods
    methods = ['wsdl', 'wsdl=', 'log', 'log=']
    assert_equal(methods.sort, (@obj.instance_methods - Object.methods).sort)
  end

end
end