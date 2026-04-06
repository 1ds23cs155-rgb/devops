import http from 'k6/http';
import { check, group, sleep } from 'k6';
import { Rate, Trend } from 'k6/metrics';

// Custom metrics
const errorRate = new Rate('errors');
const responseTime = new Trend('response_times');

// Test configuration
export const options = {
  stages: [
    { duration: '30s', target: 10 },   // Ramp-up
    { duration: '1m30s', target: 50 }, // Stay at 50 users
    { duration: '30s', target: 0 },    // Ramp-down
  ],
  thresholds: {
    'http_req_duration': ['p(95)<500'], // 95% of requests should complete within 500ms
    'http_req_failed': ['rate<0.1'],    // Error rate should be less than 10%
    'errors': ['rate<0.1'],
  },
};

const BASE_URL = __ENV.BASE_URL || 'http://localhost:3000';

export default function () {
  group('Health Check', () => {
    const res = http.get(`${BASE_URL}/health`);
    check(res, {
      'status is 200': (r) => r.status === 200,
      'response time < 200ms': (r) => r.timings.duration < 200,
      'has status field': (r) => r.json('status') === 'healthy',
    });
    responseTime.add(res.timings.duration);
    errorRate.add(res.status !== 200);
  });

  sleep(1);

  group('API Info', () => {
    const res = http.get(`${BASE_URL}/api/info`);
    check(res, {
      'status is 200': (r) => r.status === 200,
      'has app name': (r) => r.json('app').includes('DevOps'),
      'response time < 300ms': (r) => r.timings.duration < 300,
    });
    responseTime.add(res.timings.duration);
    errorRate.add(res.status !== 200);
  });

  sleep(1);

  group('Metrics Endpoint', () => {
    const res = http.get(`${BASE_URL}/metrics`);
    check(res, {
      'status is 200': (r) => r.status === 200,
      'has prometheus metrics': (r) => r.body.includes('nodejs_memory'),
    });
    responseTime.add(res.timings.duration);
    errorRate.add(res.status !== 200);
  });

  sleep(2);
}
