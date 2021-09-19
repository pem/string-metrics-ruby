#!/usr/bin/env ruby

load 'string-metrics.rb'

TestCase = Struct.new(:s1, :s2, :ld, :osad, :dld, :lcslen)

$test_cases = [
  TestCase.new( "", "", 0, 0, 0, 0 ), # Empty string
  TestCase.new( "", "abc", 3, 3, 3, 0 ), # Additions to an empty string
  TestCase.new( "abc", "", 3, 3, 3, 0),  # Delete all
  TestCase.new( "a", "a", 0, 0, 0, 1 ),  # No edit
  TestCase.new( "a", "b", 1, 1, 1, 0 ),  # Single substitution
  TestCase.new( "climax", "volmax", 3, 3, 3, 3 ), # Three substitutions
  TestCase.new( "foo123", "fool23", 1, 1, 1, 3 ), # Sneaky substitution
  TestCase.new( "test1", "test2", 1, 1, 1, 4 ),   # Single substitution again
  TestCase.new( "test1", "test11", 1, 1, 1, 5 ),  # Addition
  TestCase.new( "foobar", "foboar", 2, 1, 1, 2 ), # Transposition
  TestCase.new( "foobar", "fubar", 2, 2, 2, 3 ),  # Deletion and substitution
  TestCase.new( "password", "pa55word", 2, 2, 2, 4 ), # More substitutions
  TestCase.new( "password", "passwd", 2, 2, 2, 5 ),   # Deletion
  # Various
  TestCase.new( "book", "back", 2, 2, 2, 1 ),
  TestCase.new( "kitten", "sitting", 3, 3, 3, 3 ),
  TestCase.new( "saturday", "sunday", 3, 3, 3, 3 ),
  TestCase.new( "ca", "abc", 3, 3, 2, 1 ),
  TestCase.new( "a", "aaaaaa", 5, 5, 5, 1 ),
  TestCase.new( "pantera", "aorta", 5, 5, 4, 1 ),
  TestCase.new( "elevenbytes", "e1evenbyt3s", 2, 2, 2, 7 ),
  TestCase.new( "alongpassword", "A1ongPa55word", 5, 5, 5, 4 ),
  TestCase.new( "alongpassword", "a1ongpassw0rd1", 3, 3, 3, 8 ),
  TestCase.new( "waht", "what", 2, 1, 1, 1 ),
  TestCase.new( "thaw", "what", 2, 2, 2, 2 ),
  TestCase.new( "waht", "wait", 1, 1, 1, 2 ),
  TestCase.new( "Damerau", "uameraD", 2, 2, 2, 5 ),
  TestCase.new( "Damerau", "Daremau", 2, 2, 2, 2 ),
  TestCase.new( "Damerau", "Damreau", 2, 1, 1, 3 ),
  TestCase.new( "waht", "whit", 2, 2, 2, 1 ),
  TestCase.new( "what", "wtah", 2, 2, 2, 1 ),
  TestCase.new( "a cat", "an act", 3, 2, 2, 1 ),
  TestCase.new( "a cat", "a abct", 3, 3, 2, 2 ),
  # LCS
  TestCase.new( "foobar", "foobar123", 3, 3, 3, 6 ),
  TestCase.new( "foobar", "1foobar23", 3, 3, 3, 6 ),
  TestCase.new( "foobar", "12foobar3", 3, 3, 3, 6 ),
  TestCase.new( "foobar", "123foobar", 3, 3, 3, 6 ) ]

$maxlen = 0
$test_cases.each do |tc|
  $maxlen = tc.s1.length if tc.s1.length > $maxlen
  $maxlen = tc.s2.length if tc.s2.length > $maxlen
end

printf("%-*s %-*s   L        OSA      DL       LCSlen  LCS\n",
       $maxlen, "", $maxlen, "")

$xit = 0

$test_cases.each do |tc|
  ld = tc.s1.levenshtein_distance(tc.s2)
  ldfailed = (ld != tc.ld)
  osad = tc.s1.osa_distance(tc.s2)
  osadfailed = (osad != tc.osad)
  dld = tc.s1.dl_distance(tc.s2)
  dldfailed = (dld != tc.dld)
  lcslen = tc.s1.lcs_length(tc.s2)
  lcslenfailed = (lcslen != tc.lcslen)
  if ldfailed || osadfailed || dldfailed || lcslenfailed
    $xit = 1
  end
  printf("%-*s %-*s  %2d (%2d)%c %2d (%2d)%c %2d (%2d)%c %2d (%2d)%c %s\n",
         $maxlen, tc.s1, $maxlen, tc.s2,
         ld, tc.ld, (ldfailed  ? '*' : ' '),
         osad, tc.osad, (osadfailed ? '*' : ' '),
	 dld, tc.dld, (dldfailed ? '*' : ' '),
	 lcslen, tc.lcslen, (lcslenfailed ? '*' : ' '),
         tc.s1.lcs(tc.s2).join(' '))

end # $test_cases.each do

if $xit == 0
  puts "All tests passed"
else
  $stderr.puts "Some tests failed"
end

exit($xit)
