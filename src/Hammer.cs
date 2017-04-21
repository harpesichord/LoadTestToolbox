﻿using System;
using System.Net.Http;
using System.Threading;
using System.Threading.Tasks;

namespace LoadTestToolbox
{
    public class Hammer : Tool
    {
        private double total;

        public double Average => total / done;

        public Hammer(HttpClient httpClient, Uri url, int requests) : base(httpClient, url, requests)
        {
        }

        public override void Run()
        {
            for (var x = 0; x < _requests; x++)
            {
                var w = new Worker(_httpClient, _url);
                w.OnComplete += addResult;
                new Thread(async() => await w.Run()).Start();
            }
        }

        protected override void addResult(object returned, EventArgs e)
        {
            var length = (double)returned;
            total += length;
            Interlocked.Increment(ref done);
        }
    }
}