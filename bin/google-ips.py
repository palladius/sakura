#!/usr/bin/env python3

import json
import netaddr
import urllib.request

goog_url="www.gstatic.com/ipranges/goog.json"
cloud_url="www.gstatic.com/ipranges/cloud.json"

def read_url(url, fallback_to_http=False,attempts=2):
   if fallback_to_http:
      url = "http://" + url
   else:
      url = "https://" + url
   try:
      s = urllib.request.urlopen(url).read()
      return json.loads(s)
   except urllib.error.HTTPError:
      print("Invalid HTTP response from %s" % url)
      return {}
   except json.decoder.JSONDecodeError:
      print("Could not parse HTTP response from %s" % url)
      return {}
   except urllib.error.URLError:
      if attempts > 1:
         url = url.replace("https://","").replace("http://","")
         attempts -=1
         print("Error opening URL; trying HTTP instead of HTTPS.")
         return read_url(url,fallback_to_http=True,attempts=attempts)
      else:
         print("Error opening URL.")
         return {}

def main():
   goog_json=read_url(goog_url)
   cloud_json=read_url(cloud_url)

   if goog_json and cloud_json:
      print("{} published: {}".format(goog_url,goog_json.get('creationTime')))
      print("{} published: {}".format(cloud_url,cloud_json.get('creationTime')))
      goog_cidrs = netaddr.IPSet()
      for e in goog_json['prefixes']:
         if e.get('ipv4Prefix'):
            goog_cidrs.add(e.get('ipv4Prefix'))
      cloud_cidrs = netaddr.IPSet()
      for e in cloud_json['prefixes']:
         if e.get('ipv4Prefix'):
            cloud_cidrs.add(e.get('ipv4Prefix'))
      print("IP ranges for Google APIs and services default domains:")
      for i in goog_cidrs.difference(cloud_cidrs).iter_cidrs():
         print(i)

if __name__=='__main__':
   main()
