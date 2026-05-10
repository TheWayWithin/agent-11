export interface PageResult<T> {
  items: T[];
  page: number;
  pageSize: number;
  totalItems: number;
  totalPages: number;
}

export function paginate<T>(
  all: T[],
  page: number,
  pageSize: number
): PageResult<T> {
  const safePage = Math.max(1, Math.floor(page));
  const safeSize = Math.max(1, Math.floor(pageSize));
  const start = (safePage - 1) * safeSize;
  const end = start + safeSize;
  return {
    items: all.slice(start, end),
    page: safePage,
    pageSize: safeSize,
    totalItems: all.length,
    totalPages: Math.max(1, Math.ceil(all.length / safeSize)),
  };
}
