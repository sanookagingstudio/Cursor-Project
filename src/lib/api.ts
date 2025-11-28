/**
 * API Configuration
 * Centralized API base URL configuration
 */

// Get API URL from environment variable or use default
const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 
  (import.meta.env.DEV ? "http://localhost:8000" : "/api");

/**
 * Get full API URL for an endpoint
 * @param endpoint - API endpoint path (e.g., "/image/generate")
 * @returns Full API URL
 */
export function getApiUrl(endpoint: string): string {
  // Remove leading slash if present
  const cleanEndpoint = endpoint.startsWith("/") ? endpoint.slice(1) : endpoint;
  
  // If endpoint already includes /api, use as is
  if (cleanEndpoint.startsWith("api/")) {
    return `${API_BASE_URL}/${cleanEndpoint}`;
  }
  
  // Otherwise, prepend /api
  return `${API_BASE_URL}/api/${cleanEndpoint}`;
}

/**
 * Make API request with error handling
 */
export async function apiRequest<T = any>(
  endpoint: string,
  options: RequestInit = {}
): Promise<T> {
  const url = getApiUrl(endpoint);
  
  const response = await fetch(url, {
    ...options,
    headers: {
      "Content-Type": "application/json",
      ...options.headers,
    },
  });

  if (!response.ok) {
    const error = await response.json().catch(() => ({ detail: response.statusText }));
    throw new Error(error.detail || `API request failed: ${response.statusText}`);
  }

  return response.json();
}

/**
 * API endpoints
 */
export const API_ENDPOINTS = {
  // Health
  health: "/health",
  
  // Projects
  projects: "/projects",
  
  // Assets
  assets: "/assets",
  
  // Jobs
  jobs: "/jobs",
  
  // Workflows
  workflows: "/workflows",
  
  // Modules
  modules: "/modules",
  
  // Input Brain
  inputBrain: {
    ideas: "/input-brain/ideas",
    generateSuggestions: (ideaId: string) => `/input-brain/ideas/${ideaId}/generate-suggestions`,
    selectVersion: (ideaId: string) => `/input-brain/ideas/${ideaId}/select-version`,
    generateWorkflowDraft: (ideaId: string) => `/input-brain/ideas/${ideaId}/generate-workflow-draft`,
    workflowDrafts: "/input-brain/workflow-drafts",
    startWorkflow: (draftId: string) => `/input-brain/workflow-drafts/${draftId}/start`,
  },
  
  // Image
  image: {
    generate: "/image/generate",
    edit: "/image/edit",
    batch: "/image/batch",
    upscale: "/image/upscale",
    template: {
      apply: "/image/template/apply",
      list: "/image/templates",
      get: (id: string) => `/image/templates/${id}`,
      create: "/image/templates",
    },
    special: "/image/special",
    details: (assetId: string) => `/image/${assetId}/details`,
  },
  
  // Video
  video: {
    generate: "/video/generate",
    edit: "/video/edit",
    multiExport: "/video/multi-export",
    subtitle: "/video/subtitle",
    details: (assetId: string) => `/video/${assetId}/details`,
  },
  
  // Music
  music: {
    generate: "/music/generate",
    analyze: "/music/analyze",
    tab: "/music/tab",
    analysis: (assetId: string) => `/music/analysis/${assetId}`,
    tabDetails: (assetId: string) => `/music/tab/${assetId}`,
  },
  
  // Audio
  audio: {
    stems: "/audio/stems",
    remaster: "/audio/remaster",
    stemsDetails: (assetId: string) => `/audio/stems/${assetId}`,
  },
  
  // Dashboard
  dashboard: {
    overview: "/dashboard/overview",
    channels: "/dashboard/channels",
    channel: (id: string) => `/dashboard/channels/${id}`,
    series: (channelId: string) => `/dashboard/channels/${channelId}/series`,
    episodes: "/dashboard/episodes",
    episode: (id: string) => `/dashboard/episodes/${id}`,
    episodeSeries: (seriesId: string) => `/dashboard/series/${seriesId}/episodes`,
    performance: (episodeId: string) => `/dashboard/episodes/${episodeId}/performance`,
    finance: {
      channel: (channelId: string) => `/dashboard/channels/${channelId}/finance`,
      series: (seriesId: string) => `/dashboard/series/${seriesId}/finance`,
      episode: (episodeId: string) => `/dashboard/episodes/${episodeId}/finance`,
    },
  },
  
  // Publishing
  publishing: {
    plan: "/publishing/plan",
    episode: (episodeId: string) => `/publishing/episode/${episodeId}`,
    publication: (publicationId: string) => `/publishing/publication/${publicationId}`,
    webhook: (platform: string) => `/publishing/webhook/${platform}`,
  },
  
  // Integration
  integration: {
    runWorkflow: "/integration/workflow/run",
    createEpisodeFromAsset: "/integration/episode/create-from-asset",
    executeWorkflow: "/integration/workflow/execute",
  },
  
  // Themes
  themes: {
    list: "/themes",
    get: (id: string) => `/themes/${id}`,
    create: "/themes",
    update: (id: string) => `/themes/${id}`,
    delete: (id: string) => `/themes/${id}`,
    apply: (id: string) => `/themes/${id}/apply`,
    preview: (id: string) => `/themes/${id}/preview`,
    presets: "/themes/presets",
    export: (id: string) => `/themes/${id}/export`,
    import: "/themes/import",
    active: "/themes/active",
  },
  
  // Monetization
  monetization: {
    plans: "/monetization/plans",
    plan: (id: string) => `/monetization/plans/${id}`,
    subscriptions: "/monetization/subscriptions",
    subscription: (userId: string) => `/monetization/subscriptions/${userId}`,
    credits: {
      balance: (userId: string) => `/monetization/credits/${userId}/balance`,
      purchase: (userId: string) => `/monetization/credits/${userId}/purchase`,
      transactions: (userId: string) => `/monetization/credits/${userId}/transactions`,
    },
    payments: "/monetization/payments",
    contentPricing: "/monetization/content-pricing",
    downloads: "/monetization/downloads",
  },
  
  // Analytics
  analytics: {
    overview: "/analytics/overview",
    users: "/analytics/users",
    content: "/analytics/content",
    time: "/analytics/time",
    geographic: "/analytics/geographic",
  },
  
  // Cost Management
  cost: {
    overview: "/cost/overview",
    infrastructure: "/cost/infrastructure",
    aiProviders: "/cost/ai-providers",
    thirdParty: "/cost/third-party",
    reports: "/cost/reports",
  },
  
  // External Apps
  externalApps: {
    list: "/external-apps/applications",
    get: (id: string) => `/external-apps/applications/${id}`,
    register: "/external-apps/applications",
    update: (id: string) => `/external-apps/applications/${id}`,
    delete: (id: string) => `/external-apps/applications/${id}`,
    apiKeys: {
      list: (appId: string) => `/external-apps/applications/${appId}/api-keys`,
      generate: (appId: string) => `/external-apps/applications/${appId}/api-keys`,
      revoke: (appId: string, keyId: string) => `/external-apps/applications/${appId}/api-keys/${keyId}`,
    },
    usage: "/external-apps/usage",
  },
  
  // Discount
  discount: {
    codes: "/discount/codes",
    code: (code: string) => `/discount/codes/${code}`,
    create: "/discount/codes",
    update: (id: string) => `/discount/codes/${id}`,
    apply: "/discount/apply",
    autoApply: "/discount/auto-apply",
    best: "/discount/best",
    usage: "/discount/usage",
    analytics: (id: string) => `/discount/analytics/${id}`,
  },
};

export default API_ENDPOINTS;

