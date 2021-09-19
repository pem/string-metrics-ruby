#
# pem 2018-06-28
#
# Some "edit distance" algorithms, i.e. algorithm that measure "similarity"
# between strings. There are many, we only implement a few that might be
# useful for doing "look-alike" checks of old/new passwords.
# See https://en.wikipedia.org/wiki/String_metric for more information.
#
# The Levenshtein algorithms are a bit cryptic and are not obvious in any way;
# they are all variants of the Wagner-Fischer dynamic programming algorithm.
# For more information, see
#   https://en.wikipedia.org/wiki/Wagner-Fischer_algorithm
#
# Also included is a Longest Common Substring function.
# See: https://en.wikipedia.org/wiki/Longest_common_substring_problem
#

# Used by the lcs function
require 'set'

class String

  # Levenshtein Distance
  # See https://en.wikipedia.org/wiki/Levenshtein_distance
  def self.levenshtein_distance(s1, s2)
    v0 = Array.new(s2.length+1)
    v1 = Array.new(s2.length+1)

    v0.each_index { |i| v0[i] = i }
    0.upto(s1.length-1) do |i|
      v1[0] = i+1
      0.upto(s2.length-1) do |j|
        delcost = v0[j+1] + 1
        inscost = v1[j] + 1
        if s1[i] == s2[j]
          subcost = v0[j]
        else
          subcost = v0[j] + 1
        end
        v1[j+1] = [delcost, inscost, subcost].min
      end # 0.upto(s2.length-1) do
      v0,v1 = v1,v0
    end # 0.upto(s1.length-1) do
    return v0[s2.length]
  end # def self.levenshtein_distance

  def levenshtein_distance(s)
    String.levenshtein_distance(self, s)
  end

  # Optimal String Alignment Distance or Restricted Edit Distance
  # This is like Levenshtein Distance plus transposition.
  # See https://en.wikipedia.org/wiki/Damerau-Levenshtein_distance
  def self.osa_distance(s1, s2)
    d = Array.new(s1.length+1) { Array.new(s2.length+1) }

    0.upto(s1.length) { |i| d[i][0] = i }
    0.upto(s2.length) { |j| d[0][j] = j }

    0.upto(s1.length-1) do |i|
      0.upto(s2.length-1) do |j|
        cost = (s1[i] == s2[j] ? 0 : 1)
        d[i+1][j+1] = [d[i][j]+cost,    # subst
                       d[i][j+1]+1,     # deletion
                       d[i+1][j]+1].min # insertion
        if i > 0 && j > 0 && s1[i] == s2[j-1] && s1[i-1] == s2[j]
          # transposition
          d[i+1][j+1] = [d[i+1][j+1], d[i-1][j-1]+cost].min
        end
      end # 0.upto(s2.length-1) do
    end # 0.upto(s1.length-1) do
    return d[s1.length][s2.length]
  end # def self.osa_distance

  def osa_distance(s)
    String.osa_distance(self, s)
  end

  # Damerau-Levenshtein Distance
  # This fixes the restrictions in OSA
  # See https://en.wikipedia.org/wiki/Damerau-Levenshtein_distance
  def self.dl_distance(s1, s2)
    da = Hash.new(0)
    d = Array.new(s1.length+1) { Array.new(s2.length+1) }

    0.upto(s1.length) { |i| d[i][0] = i }
    0.upto(s2.length) { |j| d[0][j] = j }

    1.upto(s1.length) do |i|
      db = 0
      1.upto(s2.length) do |j|
        i1 = da[s2[j-1]]
        j1 = db
        cost = 0
        if s1[i-1] == s2[j-1]
          db = j
        else
          cost = 1
        end
        d[i][j] = [d[i-1][j-1]+cost, # subst
                   d[i][j-1]+1,       # insertion
                   d[i-1][j]+1].min   # deletion
        if i1 > 0 && j1 > 0
          # transposition
          d[i][j] = [d[i][j],
                     d[i1-1][j1-1] + (i-i1-1) + (j-j1-1) + 1].min
        end
      end # 1.upto(s2.length) do
      da[s1[i-1]] = i
    end # 1.upto(s1.length) do
    return d[s1.length][s2.length]
  end # def self.dl_distance

  def dl_distance(s)
    String.dl_distance(self, s)
  end

  # Return an array of the longest common substrings.
  def self.lcs(s1, s2)
    lena = Array.new(s1.length) { Array.new(s2.length) }
    z = 0
    ret = Set.new
    0.upto(s1.length-1) do |i|
      0.upto(s2.length-1) do |j|
        if s1[i] != s2[j]
          lena[i][j] = 0
        else
          if i == 0 || j == 0
            lena[i][j] = 1
          else
            lena[i][j] = lena[i-1][j-1] + 1
          end
          if lena[i][j] > z
            z = lena[i][j]
            ret = Set.new [s1[(i-z+1)..i]]
          elsif lena[i][j] == z
            ret.add s1[(i-z+1)..i]
          end
        end # if s1[i] != s2[j] else
      end # 0.upto(s2.length-1) do
    end # 0.upto(s1.length-1) do
    return ret.to_a
  end # def self.lcs

  def lcs(s)
    String.lcs(self, s)
  end

  # Return the length of the longest common substring.
  def self.lcs_length(s1, s2)
    lena = Array.new(s1.length) { Array.new(s2.length) }
    z = 0
    0.upto(s1.length-1) do |i|
      0.upto(s2.length-1) do |j|
        if s1[i] != s2[j]
          lena[i][j] = 0
        else
          if i == 0 || j == 0
            lena[i][j] = 1
          else
            lena[i][j] = lena[i-1][j-1] + 1
          end
          z = lena[i][j] if lena[i][j] > z
        end
      end # if s1[i] != s2[j] else
    end # 0.upto(s1.length-1) do
    return z
  end # def self.lcs_length

  def lcs_length(s)
    String.lcs_length(self, s)
  end

end # class String
