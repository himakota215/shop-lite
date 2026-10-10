/**
 * Validates and normalizes product query parameters
 */
function validateProductQuery(query = {}) {
  const errors = [];
  const filters = {};

  if (query.search !== undefined && query.search !== null) {
    const rawSearch = String(query.search).trim();
    if (rawSearch.length > 100) {
      errors.push('Search query must not exceed 100 characters');
    } else if (rawSearch.length > 0) {
      filters.search = rawSearch;
    }
  }

  if (query.category !== undefined && query.category !== null) {
    const rawCategory = String(query.category).trim();
    if (rawCategory.length > 50) {
      errors.push('Category query must not exceed 50 characters');
    } else if (rawCategory.length > 0 && rawCategory.toLowerCase() !== 'all') {
      filters.category = rawCategory;
    }
  }

  return {
    isValid: errors.length === 0,
    errors,
    filters
  };
}

module.exports = {
  validateProductQuery
};
